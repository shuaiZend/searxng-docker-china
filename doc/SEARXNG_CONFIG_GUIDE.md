# SearXNG 配置备忘文档

> 创建日期: 2026-01-27
> 版本: SearXNG 2026.1.23-c97d4d9b6

## 📋 目录

- [关键配置文件位置](#关键配置文件位置)
- [常见问题诊断](#常见问题诊断)
- [配置最佳实践](#配置最佳实践)
- [搜索引擎配置](#搜索引擎配置)
- [防爬虫策略](#防爬虫策略)
- [常用命令](#常用命令)

---

## 🔑 关键配置文件位置

### Docker 挂载路径

```
docker-compose.yml 配置:
  volumes:
    - ./searxng:/etc/searxng:rw
```

**实际生效的配置文件**:
- 配置文件: `./searxng/settings.yml`
- 注意: 不是 `searxng_settings.yml`（这是备份文件）

### 容器内路径

- 配置文件: `/etc/searxng/settings.yml`
- 引擎目录: `/usr/local/searxng/searx/engines/`

---

## 🔍 常见问题诊断

### 问题 1: 容器不断重启

**症状**:
```
ValueError: Invalid settings.yml
Expected `object`, got `null`
```

**常见原因**:

1. **重复的配置块**
   ```yaml
   # ❌ 错误示例
   valkey:
     url: redis://127.0.0.1:6379/0

   # ... 其他配置 ...

   valkey:  # 重复了！
     url: redis://redis:6379/0
   ```

   **解决**: 删除重复的配置块

2. **YAML 缩进错误**
   ```yaml
   # ❌ 错误的注释缩进
   # proxies:
     # all://:  # 缩进不一致
       # - http://proxy:8080

   # ✅ 正确的注释缩进
   # proxies:
   #   all://:
   #     - http://proxy:8080
   ```

3. **引擎名称错误**
   ```yaml
   # ❌ 错误
   engine: so_360

   # ✅ 正确
   engine: 360search
   ```

**诊断命令**:
```bash
# 查看容器日志
docker logs searxng --tail 50

# 检查 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('searxng/settings.yml'))"

# 检查可用引擎
docker exec searxng ls /usr/local/searxng/searx/engines/ | grep -E "(360|baidu)"
```

### 问题 2: 引擎加载失败

**症状**:
```
ERROR:searx.engines: loading engine xxx failed: set engine to inactive!
```

**解决方法**:
1. 检查引擎名称是否正确
2. 确认引擎文件存在: `docker exec searxng ls /usr/local/searxng/searx/engines/`
3. 查看完整错误日志

---

## ⚙️ 配置最佳实践

### 1. 使用默认配置

```yaml
use_default_settings: true
```

**优点**:
- 简化配置
- 自动继承官方优化
- 减少配置错误

### 2. Redis/Valkey 配置

```yaml
# ✅ 推荐使用 redis（兼容性好）
redis:
  url: redis://redis:6379/0

# ⚠️ 也可以用 valkey（会显示弃用警告）
valkey:
  url: redis://redis:6379/0
```

### 3. 服务器基础配置

```yaml
server:
  secret_key: "your-secret-key-change-me"  # 必须修改！
  limiter: false                           # 公开实例设为 true
  image_proxy: false                       # 图片代理
  method: "POST"                           # 更安全
```

---

## 🔎 搜索引擎配置

### 可用中国搜索引擎

| 引擎名 | 引擎类型 | 说明 |
|--------|---------|------|
| 360搜索 | `360search` | 需注意引擎名称 |
| 百度 | `baidu` | 有防爬虫机制 |
| 搜狗 | `sogou` | 稳定 |
| 夸克 | `quark` | 较新 |

### 基础配置模板

```yaml
engines:
  # 标准配置
  - name: bing
    engine: bing
    shortcut: bi
    disabled: false

  # 带分类的配置
  - name: google
    engine: google
    shortcut: go
    categories: [general, web]
    disabled: false

  # 低权重配置（防爬虫）
  - name: baidu
    engine: baidu
    shortcut: bd
    disabled: false
    weight: 0.3                    # 降低权重
    timeout: 8.0                   # 超时时间
    categories: [general, web]
    about:
      website: https://www.baidu.com
      use_official_api: false
      require_api_key: false
      results: HTML
      language: zh-CN
```

### 权重说明

- **默认权重**: 1.0
- **权重范围**: 0.0 - 1.0
- **计算方式**: 权重越高，被调用概率越大
- **推荐配置**:
  - 稳定引擎: 1.0（Bing、搜狗、360）
  - 易被封引擎: 0.3-0.5（百度）

---

## 🛡️ 防爬虫策略

### 全局防爬虫配置

```yaml
search:
  # 基础设置
  safe_search: 1
  autocomplete: ""
  default_lang: "zh-CN"

  # 引擎错误惩罚（关键配置）
  ban_time_on_fail: 10          # 失败后惩罚时间（秒）
  max_ban_time_on_fail: 60      # 最大惩罚时间（秒）

  # 暂停时间配置
  suspended_times:
    # 访问被拒绝（403错误）
    SearxEngineAccessDenied: 86400        # 24小时

    # CAPTCHA验证
    SearxEngineCaptcha: 86400             # 24小时

    # 请求过多（429错误）
    SearxEngineTooManyRequests: 7200      # 2小时

    # Cloudflare CAPTCHA
    cf_SearxEngineCaptcha: 1296000        # 15天
    cf_SearxEngineAccessDenied: 86400     # 24小时

    # ReCAPTCHA
    recaptcha_SearxEngineCaptcha: 604800  # 7天
```

### 多层防护策略

**第一层: 降低权重**
```yaml
weight: 0.3  # 减少70%的调用
```

**第二层: 增加超时**
```yaml
timeout: 10.0  # 给服务器更多响应时间
```

**第三层: 自动暂停**
- 触发防爬 → 自动暂停
- 避免IP被永久封禁
- 自动恢复机制

### 针对不同引擎的策略

| 引擎 | 权重 | 超时 | 说明 |
|-----|------|------|------|
| Bing | 1.0 | 5.0 | 稳定，优先使用 |
| 360 | 1.0 | 8.0 | 中文支持好 |
| 搜狗 | 1.0 | 10.0 | 较稳定 |
| 夸克 | 1.0 | 10.0 | 新引擎 |
| 百度 | 0.3 | 8.0 | 防爬虫，低权重 |
| Google | 1.0 | 5.0 | 可能需要代理 |

---

## 📝 常用命令

### 容器管理

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart searxng

# 查看日志
docker logs searxng --tail 50

# 查看实时日志
docker logs -f searxng

# 进入容器
docker exec -it searxng sh
```

### 配置管理

```bash
# 编辑配置
vi searxng/settings.yml

# 备份配置
cp searxng/settings.yml searxng/settings.yml.backup

# 验证 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('searxng/settings.yml'))"
```

### 诊断命令

```bash
# 检查服务状态
curl -I http://127.0.0.1:8088

# 检查可用引擎
docker exec searxng ls /usr/local/searxng/searx/engines/

# 查看容器状态
docker ps | grep searxng

# 查看详细信息
docker inspect searxng
```

---

## 💡 配置技巧

### 1. 快速切换搜索引擎

在搜索框使用快捷键：
```
!bi 搜索关键词    # Bing搜索
!360 搜索关键词   # 360搜索
!sg 搜索关键词    # 搜狗搜索
!wa 计算表达式    # WolframAlpha
```

### 2. 测试单个引擎

```yaml
engines:
  - name: bing
    engine: bing
    shortcut: bi
    disabled: false  # 只启用一个引擎测试
```

### 3. 逐步启用引擎

1. 先启用 1-2 个稳定引擎（Bing、360）
2. 测试无误后添加其他引擎
3. 最后添加易被封的引擎（百度）并降低权重

### 4. 性能优化

```yaml
outgoing:
  request_timeout: 15.0           # 请求超时
  max_request_timeout: 20.0       # 最大超时
  pool_connections: 50            # 连接池大小
  pool_maxsize: 10                # 最大保持连接
  enable_http2: true              # 启用HTTP/2
```

---

## 📚 相关资源

- 官方文档: https://docs.searxng.org/
- Docker项目: https://github.com/searxng/searxng-docker
- 配置参考: https://docs.searxng.org/admin/settings/
- 引擎列表: https://searxng.github.io/searxng/settings/

---

## 🔄 配置更新日志

### 2026-01-27
- ✅ 修复容器重启问题（删除重复的 valkey 配置）
- ✅ 添加中国搜索引擎（360、搜狗、夸克、百度）
- ✅ 配置百度防爬虫策略（权重 0.3）
- ✅ 增加错误惩罚机制
- ✅ 修正 360 搜索引擎名称（so_360 → 360search）

---

## 🎯 快速配置清单

部署新实例时检查：

- [ ] 修改 `secret_key`
- [ ] 配置 `redis.url`
- [ ] 启用 `use_default_settings: true`
- [ ] 配置基础搜索引擎（Bing、360、搜狗）
- [ ] 添加百度并降低权重（0.3）
- [ ] 配置防爬虫惩罚时间
- [ ] 测试服务可访问性
- [ ] 备份配置文件

---

**最后更新**: 2026-01-27
**维护者**: Claude Code Assistant
