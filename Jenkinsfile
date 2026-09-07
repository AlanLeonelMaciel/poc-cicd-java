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
                // Inyectamos las credenciales guardadas en Jenkins
                withCredentials([usernamePassword(credentialsId: 'registry-creds', passwordVariable: 'REG_PASS', usernameVariable: 'REG_USER')]) {
                    sh '''
                        # Login seguro al registry usando las variables de entorno inyectadas
                        echo "$REG_PASS" | docker login registry:5000 -u "$REG_USER" --password-stdin
                        
                        # Subimos la imagen ya autenticados
                        docker push ${IMAGE_NAME}
                    '''
                }
            }
        }
    }
}
