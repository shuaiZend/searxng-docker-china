# SearXNG 配置文档目录

本目录包含 SearXNG 的配置备忘录和参考文档。

## 📁 文档列表

### 1. [SEARXNG_CONFIG_GUIDE.md](./SEARXNG_CONFIG_GUIDE.md) - 完整配置指南
**内容**:
- 问题诊断和解决方案
- 配置最佳实践
- 搜索引擎详细配置
- 防爬虫策略详解
- 常用命令汇总
- 配置更新日志

**适用场景**: 遇到问题或需要深入了解配置时查看

---

### 2. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - 快速参考卡片
**内容**:
- 关键配置路径
- 常见问题速查表
- 推荐配置模板
- 防爬虫三件套
- 常用命令速查
- 引擎权重建议

**适用场景**: 日常快速查阅

---

### 3. [settings_template.yml](./settings_template.yml) - 配置文件模板
**内容**:
- 完整的配置文件模板
- 所有常用搜索引擎配置
- 防爬虫配置示例
- 详细的配置注释

**适用场景**:
- 部署新实例时使用
- 重置配置时参考
- 学习配置结构

---

## 🚀 快速开始

### 部署新实例

```bash
# 1. 复制模板到配置文件
cp doc/settings_template.yml searxng/settings.yml

# 2. 修改 secret_key（重要！）
vi searxng/settings.yml
# 找到这一行并修改:
# secret_key: "CHANGE-THIS-TO-A-RANDOM-STRING"

# 3. 启动服务
docker compose up -d

# 4. 检查状态
docker ps | grep searxng
curl -I http://127.0.0.1:8088
```

### 排查问题

```bash
# 1. 查看日志
docker logs searxng --tail 50

# 2. 验证配置
python3 -c "import yaml; yaml.safe_load(open('searxng/settings.yml'))"

# 3. 检查引擎
docker exec searxng ls /usr/local/searxng/searx/engines/ | grep baidu
```

---

## 📋 配置检查清单

部署前检查：

- [ ] 已修改 `secret_key` 为随机字符串
- [ ] 已配置 `redis.url` 为正确的 Redis 地址
- [ ] 已启用 `use_default_settings: true`
- [ ] 已配置基础搜索引擎（至少 2-3 个）
- [ ] 易被封引擎已降低权重（如百度 0.3）
- [ ] 已配置防爬虫惩罚时间
- [ ] YAML 语法正确（无重复块）
- [ ] 容器可以正常启动
- [ ] 服务可以正常访问
- [ ] 已备份配置文件

---

## 🔍 常见问题

**Q: 容器不断重启怎么办？**
A: 查看 [完整配置指南](./SEARXNG_CONFIG_GUIDE.md#常见问题诊断) 的"问题诊断"部分

**Q: 如何添加新搜索引擎？**
A: 参考 [配置模板](./settings_template.yml) 中的引擎配置示例

**Q: 如何避免被百度封禁？**
A: 参考 [完整配置指南](./SEARXNG_CONFIG_GUIDE.md#防爬虫策略) 的防爬虫策略

**Q: 引擎名称在哪里查找？**
A:
```bash
docker exec searxng ls /usr/local/searxng/searx/engines/
```

---

## 📚 外部资源

- **官方文档**: https://docs.searxng.org/
- **Docker项目**: https://github.com/searxng/searxng-docker
- **配置参考**: https://docs.searxng.org/admin/settings/
- **GitHub Issues**: https://github.com/searxng/searxng/issues

---

## 📝 更新记录

- **2026-01-27**: 创建文档
  - 完整配置指南
  - 快速参考卡片
  - 配置文件模板
  - 包含 360、搜狗、夸克、百度等中国搜索引擎配置

---

**维护者**: Claude Code Assistant
**最后更新**: 2026-01-27
