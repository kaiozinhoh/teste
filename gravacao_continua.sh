#!/bin/bash

# Caminhos dos arquivos de buffer, temporários e de saída
BUFFER_VIDEO_LEFT="/home/pi/video_buffer_left.mp4"    # Buffer de 25 segundos da câmera esquerda
BUFFER_VIDEO_RIGHT="/home/pi/video_buffer_right.mp4"  # Buffer de 25 segundos da câmera direita
TEMP_VIDEO_LEFT="/home/pi/video_temp_left.mp4"        # Arquivo temporário de gravação contínua da câmera esquerda
TEMP_VIDEO_RIGHT="/home/pi/video_temp_right.mp4"      # Arquivo temporário de gravação contínua da câmera direita

# URL das câmeras (substitua pelos endereços IP ou URLs RTSP das suas câmeras)
CAMERA_LEFT="rtsp://admin:senha@192.168.100.243/onvif1"  # Exemplo de câmera esquerda
CAMERA_RIGHT="rtsp://admin:senha@192.168.100.243/onvif2" # Exemplo de câmera direita

# Caminho completo para o FFmpeg (substitua pelo caminho obtido com o comando 'which ffmpeg')
FFMPEG_PATH="/usr/bin/ffmpeg"

# Função de gravação contínua para uma câmera
start_continuous_recording() {
    while true; do
        # Gravação contínua por 25 segundos para a câmera esquerda (sobrescreve o TEMP_VIDEO_LEFT)
        $FFMPEG_PATH -i $CAMERA_LEFT -t 25 -c copy -y $TEMP_VIDEO_LEFT

        # Gravação contínua por 25 segundos para a câmera direita (sobrescreve o TEMP_VIDEO_RIGHT)
        $FFMPEG_PATH -i $CAMERA_RIGHT -t 25 -c copy -y $TEMP_VIDEO_RIGHT

        # Atualiza o buffer com os últimos 25 segundos de gravação para cada câmera
        cp $TEMP_VIDEO_LEFT $BUFFER_VIDEO_LEFT
        cp $TEMP_VIDEO_RIGHT $BUFFER_VIDEO_RIGHT

        # Aguarda 1 segundo para garantir que o loop de gravação esteja sincronizado (pode ajustar conforme necessário)
        sleep 1
    done
}

# Inicia a gravação contínua
start_continuous_recording
