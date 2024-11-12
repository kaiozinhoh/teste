#!/bin/bash

# Caminhos dos arquivos de buffer, temporários e de saída
BUFFER_VIDEO_LEFT="/home/pi/video_buffer_left.mp4"    # Buffer de 25 segundos da câmera esquerda
BUFFER_VIDEO_RIGHT="/home/pi/video_buffer_right.mp4"  # Buffer de 25 segundos da câmera direita
TEMP_VIDEO="/home/pi/video_temp.mp4"                   # Arquivo temporário de gravação contínua

# URL das câmeras (substitua pelos endereços IP ou URLs RTSP das suas câmeras)
CAMERA_LEFT="rtsp://admin:kaio3005@192.168.100.243/onvif1"  # Exemplo de câmera esquerda
CAMERA_RIGHT="rtsp://admin:kaio3005@192.168.100.243/onvif2" # Exemplo de câmera direita

# Caminho completo para o FFmpeg
FFMPEG_PATH="/usr/bin/ffmpeg"

# Diretorio de logs
LOG_DIR="/home/pi/"

# Cria o diretório de logs caso não exista
mkdir -p $LOG_DIR

# Função de gravação contínua para uma câmera
start_continuous_recording() {
    while true; do
        # Gravação contínua para ambas as câmeras (5 minutos de gravação contínua)
        echo "Iniciando gravação contínua das câmeras... (5 minutos cada)"
        
        # Gravação contínua para a câmera esquerda (H.265 -> H.264, ou diretamente H.265 dependendo da compatibilidade)
        $FFMPEG_PATH -rtsp_transport udp -i $CAMERA_LEFT -t 300 -c:v libx264 -c:a aac -strict experimental -y $TEMP_VIDEO 2>&1 | tee $LOG_DIR/ffmpeg_log_left.txt
        
        # Gravação contínua para a câmera direita (H.265 -> H.264, ou diretamente H.265 dependendo da compatibilidade)
        $FFMPEG_PATH -rtsp_transport udp -i $CAMERA_RIGHT -t 300 -c:v libx264 -c:a aac -strict experimental -y $TEMP_VIDEO 2>&1 | tee $LOG_DIR/ffmpeg_log_right.txt

        # Atualiza o buffer com os últimos 25 segundos de gravação para cada câmera
        cp $TEMP_VIDEO $BUFFER_VIDEO_LEFT
        cp $TEMP_VIDEO $BUFFER_VIDEO_RIGHT

        # Aguarda 1 segundo para garantir que o loop de gravação esteja sincronizado
        sleep 1
    done
}

# Inicia a gravação contínua
start_continuous_recording
