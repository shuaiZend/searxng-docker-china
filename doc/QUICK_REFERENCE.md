# SearXNG 快速参考

## 🔥 关键配置路径

```
配置文件: ./searxng/settings.yml  ← 实际生效
备份文件: ./searxng_settings.yml  ← 不生效
```

## ⚡ 常见问题速查

| 症状 | 原因 | 解决 |
|-----|------|------|
| 容器重启 | YAML 重复块 | 删除重复的 valkey/redis 配置 |
| 引擎失败 | 引擎名错误 | 检查 `ls /usr/local/searxng/searx/engines/` |
| 403 错误 | 防爬虫 | 降低 weight 或增加 ban_time |

## 🎯 推荐配置

```yaml
use_default_settings: true

redis:
  url: redis://redis:6379/0

search:
  default_lang: "zh-CN"
  ban_time_on_fail: 10
  max_ban_time_on_fail: 60

engines:
  # 稳定引擎 - 权重 1.0
  - name: bing
    engine: bing
    shortcut: bi
    disabled: false

  # 防爬虫引擎 - 权重 0.3
  - name: baidu
    engine: baidu
    shortcut: bd
    weight: 0.3
    timeout: 8.0
```

## 🛡️ 防爬虫三件套

1. **降低权重**: `weight: 0.3`
2. **增加超时**: `timeout: 10.0`
3. **自动暂停**: `suspended_times` 配置

## 🔧 常用命令

```bash
# 重启服务
docker compose restart searxng

# 查看日志
docker logs searxng --tail 50

# 检查状态
curl -I http://127.0.0.1:8088

# 验证配置
python3 -c "import yaml; yaml.safe_load(open('searxng/settings.yml'))"
```

## 📊 引擎权重建议

| 引擎 | 权重 | 说明 |
|-----|------|------|
| Bing/360/搜狗 | 1.0 | 优先使用 |
| 百度 | 0.3 | 防爬虫 |
| Google | 1.0 | 需代理 |

## 🚨 避坑指南

1. ❌ 不要用 `valkey`，用 `redis`
2. ❌ 不要重复配置块
3. ❌ 引擎名别写错（`360search` 不是 `so_360`）
4. ✅ 修改后要重启容器
5. ✅ 先备份配置文件

## 📱 搜索快捷键

```
!bi 关键词  → Bing
!360 关键词 → 360搜索
!sg 关键词  → 搜狗
!wa 计算    → WolframAlpha
```

---

**详细文档**: 见 `SEARXNG_CONFIG_GUIDE.md`
