#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Supabase
SUPABASE_URL="https://jipoyolkubgpcubkjcxi.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppcG95b2xrdWJncGN1YmtqY3hpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExMTQ0NDgsImV4cCI6MjA1NjY5MDQ0OH0.kbyRhp3u7IUcjMOWcB6WDCNQsFqzPs1AQerKumw0CBs"

echo -e "${BLUE}🚀 Configuration de SENFLIX avec Supabase${NC}"

# Vérifier si curl est installé
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl n'est pas installé. Installation...${NC}"
    sudo apt-get update && sudo apt-get install -y curl
fi

# Vérifier si jq est installé
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq n'est pas installé. Installation...${NC}"
    sudo apt-get update && sudo apt-get install -y jq
fi

echo -e "${BLUE}📦 Installation des dépendances NPM...${NC}"
npm install

echo -e "${BLUE}🔧 Configuration de la base de données...${NC}"

# Lire le contenu du fichier SQL
SQL_CONTENT=$(cat database/setup.sql)

# Exécuter le script SQL via l'API REST de Supabase
echo -e "${BLUE}⚙️ Exécution du script SQL...${NC}"
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/exec_sql" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"${SQL_CONTENT}\"}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration de la base de données terminée${NC}"
else
    echo -e "${RED}❌ Erreur lors de la configuration de la base de données${NC}"
fi

echo -e "${BLUE}🔐 Configuration de l'authentification...${NC}"

# Configuration de l'authentification
AUTH_CONFIG='{
    "site_url": "http://localhost:8000",
    "additional_redirect_urls": [
        "http://localhost:8000/login.html",
        "http://localhost:8000/profiles.html"
    ],
    "jwt_exp": 3600,
    "max_session_length": "720h",
    "security_update_frequency": "24h",
    "confirm_email": true
}'

curl -X PUT "${SUPABASE_URL}/auth/v1/config" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -d "${AUTH_CONFIG}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration de l'authentification terminée${NC}"
else
    echo -e "${RED}❌ Erreur lors de la configuration de l'authentification${NC}"
fi

echo -e "${BLUE}📧 Configuration des templates d'emails...${NC}"

# Configuration des templates d'emails
EMAIL_TEMPLATES='{
    "templates": {
        "confirmation": {
            "subject": "Confirmez votre inscription à SENFLIX",
            "content": "<h2>Confirmez votre inscription à SENFLIX</h2><p>Cliquez sur le lien ci-dessous pour confirmer votre adresse email :</p><p><a href=\"{{ .ConfirmationURL }}\">Confirmer mon email</a></p>"
        },
        "recovery": {
            "subject": "Réinitialisation de votre mot de passe SENFLIX",
            "content": "<h2>Réinitialisation de votre mot de passe SENFLIX</h2><p>Cliquez sur le lien ci-dessous pour réinitialiser votre mot de passe :</p><p><a href=\"{{ .ConfirmationURL }}\">Réinitialiser mon mot de passe</a></p>"
        }
    }
}'

curl -X PUT "${SUPABASE_URL}/auth/v1/template" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -d "${EMAIL_TEMPLATES}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration des templates d'emails terminée${NC}"
else
    echo -e "${RED}❌ Erreur lors de la configuration des templates d'emails${NC}"
fi

echo -e "${GREEN}✨ Configuration terminée !${NC}"
echo -e "${BLUE}📝 Pour démarrer le serveur : ${NC}npm start"
echo -e "${BLUE}🌐 L'application sera accessible à : ${NC}http://localhost:8000"
