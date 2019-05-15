@echo off
:: Used to pull a fresh image from Dockerhub
docker pull mrklees/acmplacement:latest
:: Finally, conveniently open chrome to localhost at the target port.
start chrome --new-window "http://localhost:8000"
:: Then run the image. -p 8000:8000 exposes the 8000 port so that we can see the app in the browser.
docker run -it -p 8000:8000 mrklees/acmplacement:latest
