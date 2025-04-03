from flask import Flask, request, jsonify
from twilio.rest import Client
from twilio.twiml.voice_response import VoiceResponse
from transformers import pipeline
import os
from dotenv import load_dotenv
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Twilio configuration
account_sid = os.getenv('TWILIO_ACCOUNT_SID')
auth_token = os.getenv('TWILIO_AUTH_TOKEN')
twilio_number = os.getenv('TWILIO_PHONE_NUMBER')

try:
    client = Client(account_sid, auth_token)
except Exception as e:
    logger.error(f"Failed to initialize Twilio client: {e}")
    client = None

# Initialize the medicine-LLM model
try:
    model = pipeline('text-generation', model='AdaptLLM/medicine-LLM')
    logger.info("Successfully loaded medicine-LLM model")
except Exception as e:
    logger.error(f"Failed to load medicine-LLM model: {e}")
    model = None

# In-memory storage for call data
# Note: This will reset when the PythonAnywhere app reloads
call_data = {}

@app.route('/api/request-callback', methods=['POST'])
def request_callback():
    try:
        if not client:
            return jsonify({'error': 'Twilio client not initialized'}), 500
            
        data = request.json
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        phone_number = data.get('phone_number')
        if not phone_number:
            return jsonify({'error': 'Phone number is required'}), 400
            
        language = data.get('language', 'en')
        health_concern = data.get('health_concern', '')
        
        # Store call data
        call_data[phone_number] = {
            'language': language,
            'health_concern': health_concern
        }
        
        # Make the outbound call
        callback_url = f"https://ftttmhhhh.pythonanywhere.com/handle-call"
        call = client.calls.create(
            url=callback_url,
            to=phone_number,
            from_=twilio_number
        )
        
        logger.info(f"Initiated callback to {phone_number}, call SID: {call.sid}")
        return jsonify({
            'message': 'Callback requested successfully',
            'call_sid': call.sid
        }), 200
        
    except Exception as e:
        logger.error(f"Error in request_callback: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/handle-call', methods=['POST'])
def handle_call():
    response = VoiceResponse()
    try:
        if not model:
            response.say("I apologize, but our AI system is currently unavailable. Please try again later.")
            return str(response)
        
        phone_number = request.values.get('To')
        call_info = call_data.get(phone_number, {})
        health_concern = call_info.get('health_concern', '')
        
        if health_concern:
            # Generate medical advice using medicine-LLM
            prompt = f"Question: {health_concern}\nPlease provide medical advice."
            advice = model(prompt, 
                         max_length=200,
                         num_return_sequences=1)[0]['generated_text']
            
            response.say(advice, voice='alice')
        else:
            response.say("Welcome to AI Health Assistant. Please describe your health concern.", 
                        voice='alice')
            response.record(maxLength=30,
                          action='/process-recording',
                          transcribe=True)
        
    except Exception as e:
        logger.error(f"Error in handle_call: {e}")
        response.say("I apologize, but I encountered an error. Please try again later.")
    
    return str(response)

@app.route('/process-recording', methods=['POST'])
def process_recording():
    response = VoiceResponse()
    try:
        if not model:
            response.say("I apologize, but our AI system is currently unavailable. Please try again later.")
            return str(response)
            
        transcription = request.values.get('TranscriptionText', '')
        if transcription:
            prompt = f"Question: {transcription}\nPlease provide medical advice."
            advice = model(prompt,
                         max_length=200,
                         num_return_sequences=1)[0]['generated_text']
            
            response.say(advice, voice='alice')
        else:
            response.say("I'm sorry, I couldn't understand that. Please try again.")
            
    except Exception as e:
        logger.error(f"Error in process_recording: {e}")
        response.say("I apologize, but I encountered an error. Please try again later.")
    
    return str(response)

# For PythonAnywhere deployment
application = app

if __name__ == '__main__':
    app.run(debug=True) 