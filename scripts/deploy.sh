#!/bin/bash

STATE_FILE="/etc/nginx/current_deploy.env"

source $STATE_FILE

echo ">>> Color activo actualmente: $ACTIVE_COLOR"

if [ "$ACTIVE_COLOR" == "blue" ]; then
    TARGET_COLOR="green"
    export APP_TARGET_IP="192.168.1.20"
    export APP_TARGET_PORT="8081"
else
    TARGET_COLOR="blue"
    export APP_TARGET_IP="192.168.1.10"
    export APP_TARGET_PORT="8080"
fi

export DEPLOYMENT_COLOR=$TARGET_COLOR

echo ">>> Desplegando hacia: $TARGET_COLOR"
echo ">>> Destino: $APP_TARGET_IP:$APP_TARGET_PORT"

envsubst '${APP_TARGET_IP} ${APP_TARGET_PORT} ${DEPLOYMENT_COLOR}' \
    < /etc/nginx/templates/nginx.conf.template \
    > /etc/nginx/conf.d/default.conf

nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx

    tee $STATE_FILE > /dev/null <<ENVEOF
ACTIVE_COLOR=$TARGET_COLOR
APP_TARGET_IP=$APP_TARGET_IP
APP_TARGET_PORT=$APP_TARGET_PORT
ENVEOF

    echo ">>> Estado actualizado. Color productivo ahora: $TARGET_COLOR"
else
    echo "Error de sintaxis. No se aplicaron cambios."
    exit 1
fi
