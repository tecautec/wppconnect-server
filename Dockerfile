# Node LTS + Debian (estável para Chrome)
FROM node:18-bullseye

# Instala Google Chrome e libs necessárias para rodar headless no Railway
RUN apt-get update && apt-get install -y wget gnupg ca-certificates && \
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable \
      libxshmfence1 libgbm1 libasound2 libatk1.0-0 libcairo2 libdbus-1-3 libgconf-2-4 \
      libgdk-pixbuf-2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-6 libxcomposite1 \
      libxdamage1 libxrandr2 libxss1 libxtst6 fonts-liberation xdg-utils && \
    rm -rf /var/lib/apt/lists/*

# Diz ao Puppeteer para usar o Chrome já instalado (e não baixar outro)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

WORKDIR /app
COPY . .

# Instala dependências e compila o servidor
RUN yarn install --frozen-lockfile && yarn build

ENV HOST=0.0.0.0
ENV PORT=21465
EXPOSE 21465

CMD ["node", "dist/server.js"]
