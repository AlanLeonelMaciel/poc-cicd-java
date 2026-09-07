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
	stage('Deploy DEV') {
            steps {
                echo "Desplegando versión ${SHORT_COMMIT} en el Host mediante SSH..."
                
                // 1. Inyectamos las credenciales del Registry (usuario y contraseña)
                withCredentials([usernamePassword(credentialsId: 'registry-creds', passwordVariable: 'REG_PASS', usernameVariable: 'REG_USER')]) {
                    
                    // 2. Inyectamos la llave SSH que acabas de crear
                    sshagent(credentials: ['host-ssh-creds']) {
                        sh '''
                            # Instalamos el cliente SSH en el agente Alpine
                            apk add --no-cache openssh-client || true
                            
                            # Preparamos el comando SSH desactivando el host key checking para que no pida confirmación manual
                            SSH_CMD="ssh -o StrictHostKeyChecking=no amaciel2@192.168.122.187"

                            # Ejecutamos toda la secuencia de despliegue dentro del Host
                            $SSH_CMD "
                                echo '$REG_PASS' | docker login registry:5000 -u '$REG_USER' --password-stdin
                                docker pull registry:5000/mi-app:${SHORT_COMMIT}
                                docker stop mi-app-dev || true
                                docker rm mi-app-dev || true
                                docker run -d --name mi-app-dev -p 8080:8080 registry:5000/mi-app:${SHORT_COMMIT}
                            "
                        '''
                    }
                }
            }
        }
    }
}
