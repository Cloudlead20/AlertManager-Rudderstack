from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/alert', methods=['POST'])
def handle_alert():
    data = request.json
    # Log the received alert
    print(f"Received alert: {data}")
    # Example action: Print to console (you can add more actions here)
    return jsonify({"status": "success"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
