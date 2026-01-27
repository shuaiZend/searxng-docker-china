# SearXNG Docker - 中国用户优化配置

> 为中国地区用户优化的 SearXNG 私有搜索引擎部署方案

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![SearXNG](https://img.shields.io/badge/SearXNG-2026.1.23-green.svg)](https://github.com/searxng/searxng)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

## ✨ 特性

- 🇨🇳 **中文优化**: 预配置国内搜索引擎（360搜索、搜狗、夸克、百度）
- 🛡️ **防爬虫策略**: 智能权重调节，避免被搜索引擎封禁
- ⚡ **即开即用**: 一键部署，无需复杂配置
- 🔒 **隐私保护**: 不追踪、不记录、不收集用户数据
- 🎯 **多引擎聚合**: 同时使用多个搜索引擎，结果更全面
- 🚀 **自动 SSL**: 集成 Caddy 自动 HTTPS 证书
- 💾 **Redis 缓存**: 提升搜索性能

## 📦 包含的搜索引擎

| 搜索引擎 | 权重 | 说明 |
|---------|------|------|
| Bing | ⭐⭐⭐⭐⭐ | 稳定可靠 |
| 360 搜索 | ⭐⭐⭐⭐⭐ | 中文支持好 |
| 搜狗 | ⭐⭐⭐⭐⭐ | 国内稳定 |
| 夸克 | ⭐⭐⭐⭐⭐ | 新兴引擎 |
| WolframAlpha | ⭐⭐⭐⭐⭐ | 知识计算 |
| 百度 | ⭐⭐ | 低权重防封禁 |
| Google | ⭐⭐⭐⭐⭐ | 国际搜索 |
| DuckDuckGo | ⭐⭐⭐⭐⭐ | 隐私优先 |

## 🚀 快速开始

### 前置要求

- Docker
- Docker Compose v2+

### 一键部署

```bash
# 1. 克隆项目
git clone https://github.com/YOUR_USERNAME/searxng-docker-china.git
cd searxng-docker-china

# 2. 启动服务
docker compose up -d

# 3. 访问服务
# 浏览器打开: http://localhost:8088
```

### 验证部署

```bash
# 检查容器状态
docker ps | grep searxng

# 检查服务健康
curl -I http://localhost:8088
```

## 📂 项目结构

```
searxng-docker-china/
├── docker-compose.yml        # Docker Compose 配置
├── Caddyfile                # Caddy 反向代理配置
├── searxng/                  # SearXNG 配置目录
│   ├── settings.yml         # 主配置文件（已优化）
│   ├── uwsgi.ini           # WSGI 配置
│   └── data/               # 数据目录
├── doc/                     # 配置文档
│   ├── README.md           # 文档索引
│   ├── QUICK_REFERENCE.md  # 快速参考
│   ├── SEARXNG_CONFIG_GUIDE.md  # 完整指南
│   └── settings_template.yml    # 配置模板
├── .gitignore              # Git 忽略文件
├── LICENSE                 # MIT 许可证
└── README.md               # 项目说明
```

## ⚙️ 配置说明

### 防爬虫优化

针对百度等有防爬虫机制的搜索引擎，已实施以下策略：

1. **降低权重**: 百度权重设为 0.3，减少 70% 调用
2. **智能暂停**: 触发防爬自动暂停 2-24 小时
3. **超时保护**: 增加超时时间避免请求失败

```yaml
# 百度防爬虫配置示例
- name: baidu
  engine: baidu
  weight: 0.3                    # 降低权重
  timeout: 8.0                   # 增加超时
```

### 自定义配置

编辑 `searxng/settings.yml` 文件：

```yaml
# 修改默认语言
search:
  default_lang: "zh-CN"          # 中文
  # default_lang: "en"           # 英文

# 添加/删除搜索引擎
engines:
  - name: your_engine
    engine: engine_name
    disabled: false
```

修改后重启服务：
```bash
docker compose restart searxng
```

## 🔧 高级配置

### 配置域名（可选）

1. 创建 `.env` 文件：
```env
SEARXNG_HOSTNAME=your-domain.com
SEARXNG_EMAIL=admin@your-domain.com
```

2. 启用 Caddy（已包含在 docker-compose.yml 中）

### 修改端口

编辑 `docker-compose.yml`：

```yaml
services:
  searxng:
    ports:
      - "8088:8080"  # 修改左侧端口
```

## 📖 使用指南

### 搜索快捷键

在搜索框中使用快捷键指定搜索引擎：

```
!bi 关键词    → Bing 搜索
!360 关键词   → 360 搜索
!sg 关键词    → 搜狗搜索
!wa 计算式    → WolframAlpha 计算
!bd 关键词    → 百度搜索（低频）
```

### API 使用

```bash
# 基本搜索
curl "http://localhost:8088/search?q=测试&format=json"

# 指定引擎
curl "http://localhost:8088/search?q=测试&engines=bing,360&format=json"

# JSON 格式
curl "http://localhost:8088/search?q=测试&format=json"

# RSS 格式
curl "http://localhost:8088/search?q=测试&format=rss"
```

## 🛠️ 故障排查

### 容器无法启动

```bash
# 查看日志
docker logs searxng

# 常见问题：配置文件错误
# 解决：检查 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('searxng/settings.yml'))"
```

### 搜索引擎不可用

```bash
# 检查引擎名称
docker exec searxng ls /usr/local/searxng/searx/engines/ | grep baidu

# 查看详细日志
docker logs searxng | grep -i error
```

### 更多问题

查看 [完整配置指南](./doc/SEARXNG_CONFIG_GUIDE.md)

## 📚 文档

- [快速参考](./doc/QUICK_REFERENCE.md) - 常用命令和配置速查
- [完整指南](./doc/SEARXNG_CONFIG_GUIDE.md) - 详细配置和优化说明
- [配置模板](./doc/settings_template.yml) - 完整配置文件模板

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📝 更新日志

### v1.0.0 (2026-01-27)

- ✅ 初始版本
- ✅ 配置中国搜索引擎（360、搜狗、夸克、百度）
- ✅ 实施防爬虫策略
- ✅ 优化权重配置
- ✅ 完善文档和使用指南
- ✅ 集成 Caddy 自动 HTTPS

## ⚠️ 注意事项

1. **Secret Key**: 首次部署前建议修改 `searxng/settings.yml` 中的 `secret_key`
2. **公网部署**: 如需公网访问，请配置域名并启用 Caddy
3. **搜索引擎**: 部分搜索引擎可能需要代理才能访问（如 Google）
4. **资源占用**: 建议至少 1GB RAM

## 🔒 安全建议

1. 修改默认的 `secret_key`
2. 公网部署时启用 `limiter: true`
3. 使用强密码保护管理界面
4. 定期更新 Docker 镜像
5. 限制管理接口的访问权限

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [SearXNG](https://github.com/searxng/searxng) - 优秀的开源搜索引擎
- [searxng-docker](https://github.com/searxng/searxng-docker) - Docker 部署方案

## 📮 联系方式

- Issues: [GitHub Issues](https://github.com/YOUR_USERNAME/searxng-docker-china/issues)

---

**如果这个项目对你有帮助，请给个 ⭐️ Star！**
