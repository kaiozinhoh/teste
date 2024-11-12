#!/bin/bash

# Caminhos dos arquivos de buffer, temporários e de saída
BUFFER_VIDEO_LEFT="/home/kaio/pi/video_buffer_left.mp4"    # Buffer de 25 segundos da câmera esquerda
BUFFER_VIDEO_RIGHT="/home/kaio/pi/video_buffer_right.mp4"  # Buffer de 25 segundos da câmera direita
TEMP_VIDEO_LEFT="/home/kaio/pi/video_temp_left.mp4"        # Arquivo temporário de gravação contínua da câmera esquerda
TEMP_VIDEO_RIGHT="/home/kaio/pi/video_temp_right.mp4"      # Arquivo temporário de gravação contínua da câmera direita

# URL das câmeras (substitua pelos endereços IP ou URLs RTSP das suas câmeras)
CAMERA_LEFT="rtsp://admin:kaio3005@192.168.100.163/onvif1"  # Exemplo de câmera esquerda
CAMERA_RIGHT="rtsp://admin:kaio3005@192.168.100.163/onvif2" # Exemplo de câmera direita

# Caminho completo para o FFmpeg (substitua pelo caminho obtido com o comando 'which ffmpeg')
FFMPEG_PATH="/usr/bin/ffmpeg"

# Função de gravação contínua para uma câmera
start_continuous_recording() {
    while true; do
        # Gravação contínua por 25 segundos para a câmera esquerda (sobrescreve o TEMP_VIDEO_LEFT)
        $FFMPEG_PATH -rtsp_transport tcp -i $CAMERA_LEFT -t 25 -c copy -an -y $TEMP_VIDEO_LEFT 2>&1 | tee /home/pi/ffmpeg_log_left.txt

        # Gravação contínua por 25 segundos para a câmera direita (sobrescreve o TEMP_VIDEO_RIGHT)
        $FFMPEG_PATH -rtsp_transport tcp -i $CAMERA_RIGHT -t 25 -c copy -an -y $TEMP_VIDEO_RIGHT 2>&1 | tee /home/pi/ffmpeg_log_right.txt

        # Atualiza o buffer com os últimos 25 segundos de gravação para cada câmera
        cp $TEMP_VIDEO_LEFT $BUFFER_VIDEO_LEFT
        cp $TEMP_VIDEO_RIGHT $BUFFER_VIDEO_RIGHT

        # Aguarda 1 segundo para garantir que o loop de gravação esteja sincronizado
        sleep 1
    done
}

# Inicia a gravação contínua
start_continuous_recording
