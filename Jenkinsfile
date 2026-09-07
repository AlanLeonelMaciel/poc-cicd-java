pipeline {
    // Si tu agente tiene una etiqueta específica como 'docker', cambiala aquí
    agent {
       label 'docker-agent'
    } 

    environment {
        // Obtenemos los primeros 7 caracteres del commit
        SHORT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        // Armamos el nombre de la imagen apuntando a tu registry
        IMAGE_NAME = "registry:5000/mi-app:${SHORT_COMMIT}"
    }

    stages {
        stage('Build Image') {
            steps {
                echo "Construyendo imagen para el commit: ${SHORT_COMMIT}"
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Push al Registry') {
            steps {
                echo "Subiendo imagen al registry local..."
                sh "docker push ${IMAGE_NAME}"
            }
        }
    }
}
