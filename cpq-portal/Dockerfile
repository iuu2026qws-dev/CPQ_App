# CPQ Portal 前端 Dockerfile（S21.1）
# 多阶段构建：Node build → Nginx serve
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --ignore-engines --legacy-peer-deps
COPY . .
RUN npm run build

FROM nginx:1.26-alpine
# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html
# Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
