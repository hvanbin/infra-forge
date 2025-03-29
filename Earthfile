VERSION --try 0.8

all:
    BUILD +containerize

containerize:
    FROM docker.io/nginx:1.27
    COPY --dir nginx/conf.d /etc/nginx
    COPY nginx/.htpasswd /etc/nginx/.htpasswd
    SAVE IMAGE "backstead":0.1.4

