# Alert Manager System

## Overview

This repository provides a system for managing alerts programmatically. The system includes functionalities to:
1. **Receive**: Capture alerts via a webhook.
2. **Enrich**: Enhance alert data with additional information.
3. **Take Action**: Perform actions such as sending notifications to Slack or other services.

The solution is designed to be extensible, allowing developers to add new alert handling pipelines easily. The system is set up in a demo-able state using GitHub Codespaces and KinD (Kubernetes IN Docker).

## Requirements

- **Webhook**: To receive alerts.
- **Enrichment**: Functionality to enrich alert data.
- **Action**: Capability to trigger actions like sending messages to Slack.
- **Extendability**: Support for additional alert types and actions.
- **Observability** (Bonus): Monitoring and observability features.

## Implementation

### Technology Stack

- **Programming Language**: Python (or any preferred language)
- **Framework**: Flask (for web server)
- **Kubernetes Tool**: KinD (Kubernetes IN Docker)
- **Monitoring**: Prometheus and Alertmanager

### Setup

1. **Open Repository in GitHub Codespaces**

   - Navigate to [alert-manager-system](https://organic-eureka-r44pj6wjqpwpcxjgq.github.dev/).
   - Click on the green **Code** button and select **Open with Codespaces**.
   - Create a new Codespace or select an existing one.

2. **Install Dependencies**

   - In the Codespaces terminal, install required tools:

     ```bash
     sudo apt-get update
     sudo apt-get install -y curl python3-pip
     curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
     pip3 install flask requests
     ```

3. **Create KinD Cluster**

   - Create a `kind-config.yaml` file:

     ```yaml
     kind: Cluster
     apiVersion: kind.sigs.k8s.io/v1alpha4
     networking:
       disableDefaultCNI: false
       podSubnet: 192.168.0.0/16
       serviceSubnet: 10.96.0.0/12
       dnsDomain: cluster.local
     nodes:
       - role: control-plane
       - role: worker
     ```

   - Create the cluster:

     ```bash
     kind create cluster --config kind-config.yaml
     ```

   - Verify the cluster:

     ```bash
     kubectl cluster-info
     ```

4. **Deploy Prometheus and Alertmanager**

   - Apply Prometheus and Alertmanager configurations:

     ```bash
     kubectl apply -f https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1-linux-amd64.tar.gz
     ```

5. **Deploy the Alert Manager System**

   - **Webhook Server**: Create a `server.py` file:

     ```python
     from flask import Flask, request, jsonify
     import requests

     app = Flask(__name__)

     @app.route('/alert', methods=['POST'])
     def handle_alert():
         data = request.json
         # Enrich data (example function)
         enriched_data = enrich_data(data)
         # Send Slack notification (example function)
         send_slack_notification(enriched_data)
         return jsonify({"status": "alert processed"}), 200

     def enrich_data(data):
         # Example enrichment logic
         return data

     def send_slack_notification(data):
         # Example Slack notification logic
         slack_webhook_url = "YOUR_SLACK_WEBHOOK_URL"
         payload = {
             "text": f"Alert received: {data}"
         }
         requests.post(slack_webhook_url, json=payload)

     if __name__ == '__main__':
         app.run(host='0.0.0.0', port=5000)
     ```

   - **Deployment and Service**: Create `deployment.yaml` and `service.yaml`:

     - `deployment.yaml`:

       ```yaml
       apiVersion: apps/v1
       kind: Deployment
       metadata:
         name: alert-manager
       spec:
         replicas: 1
         selector:
           matchLabels:
             app: alert-manager
         template:
           metadata:
             labels:
               app: alert-manager
           spec:
             containers:
               - name: alert-manager
                 image: python:3.8
                 command: ["python3", "/app/server.py"]
                 ports:
                   - containerPort: 5000
       ```

     - `service.yaml`:

       ```yaml
       apiVersion: v1
       kind: Service
       metadata:
         name: alert-manager-service
       spec:
         type: LoadBalancer
         selector:
           app: alert-manager
         ports:
           - protocol: TCP
             port: 80
             targetPort: 5000
       ```

   - Deploy these configurations:

     ```bash
     kubectl apply -f deployment.yaml
     kubectl apply -f service.yaml
     ```

## Accessing the Application

1. **GitHub Codespaces Access**

   - The application is deployed in GitHub Codespaces.
   - Access the application at [GitHub Codespaces URL](https://organic-eureka-r44pj6wjqpwpcxjgq.github.dev/).

2. **Port Forwarding**

   - Use port forwarding to access the application locally (if needed):

     ```bash
     kubectl port-forward service/alert-manager-service 8080:80
     ```

   - Access the application at [http://localhost:8080](http://localhost:8080).

3. **External Access**

   - For cloud-based access, get the external IP:

     ```bash
     kubectl get services
     ```

   - Access the application using the provided external IP.

## Extending the System

1. **Adding New Alert Handlers**

   To add support for new alert types:

   - Update `server.py` with new enrichment and action logic.
   - Modify webhook handling to accommodate new alert types.

2. **Documentation**

   - Update this README to include details about new alert types and actions.
   - Ensure implementation of new features is documented clearly.

## Observability

1. **Enable Observability**

   - Ensure Prometheus and Alertmanager are properly configured to monitor alerts.
   - Set up Grafana or other monitoring tools if needed.

## Troubleshooting

- **Cluster Issues**: Ensure KinD and Kubernetes configurations are correct. Check logs for errors.
- **Deployment Issues**: Verify YAML files and container logs using `kubectl logs`.
- **Webhook Not Receiving**: Check network configurations and endpoint availability.
