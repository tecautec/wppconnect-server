# Usa exatamente a versão exigida pelo @wppconnect/server
FROM node:22.18.0-bookworm

# Instala Google Chrome + libs necessárias para headless
RUN apt-get update \
 && apt-get install -y wget gnupg ca-certificates \
 && wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux-keyring.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      google-chrome-stable \
      fonts-liberation libasound2 libatk-bridge2.0-0 libatspi2.0-0 libatk1.0-0 \
      libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
      libnss3 libxrandr2 libgbm1 libgtk-3-0 libxshmfence1 \
 && rm -rf /var/lib/apt/lists/*

# Puppeteer usa o Chrome do sistema (não baixa Chromium)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

WORKDIR /app
COPY . .

# Instala dependências (mantive o ignore-engines por segurança)
RUN yarn install --frozen-lockfile --ignore-engines

# Build do servidor
RUN yarn build

# Porta padrão do wppconnect-server
EXPOSE 21465

# Inicia o serviço (tenta scripts comuns)
CMD ["sh", "-lc", "yarn start:prod || yarn start || node dist/server.js"]
