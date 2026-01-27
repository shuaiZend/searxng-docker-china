#!/bin/bash

# SearXNG Docker China - GitHub 发布脚本
# 使用方法: ./publish_to_github.sh

set -e

echo "======================================"
echo "SearXNG Docker China - GitHub 发布助手"
echo "======================================"
echo ""

# 检查是否已初始化 Git
if [ ! -d .git ]; then
    echo "❌ 错误: 当前目录不是 Git 仓库"
    echo "请先运行: git init"
    exit 1
fi

# 提示用户输入 GitHub 信息
echo "请输入您的 GitHub 用户名: "
read -r GITHUB_USERNAME

echo ""
echo "请输入项目名称 (默认: searxng-docker-china): "
read -r REPO_NAME
REPO_NAME=${REPO_NAME:-searxng-docker-china}

echo ""
echo "======================================"
echo "项目信息确认"
echo "======================================"
echo "GitHub 用户名: $GITHUB_USERNAME"
echo "项目名称: $REPO_NAME"
echo "仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "按回车键继续，或 Ctrl+C 取消..."
read

# 创建 GitHub 仓库的提示
echo ""
echo "======================================"
echo "步骤 1: 在 GitHub 创建新仓库"
echo "======================================"
echo ""
echo "1. 访问: https://github.com/new"
echo "2. 仓库名称: $REPO_NAME"
echo "3. 描述: SearXNG Docker - 中国用户优化配置"
echo "4. 可见性: 公开 或 私有"
echo "5. ❌ 不要初始化 README、.gitignore 或 LICENSE"
echo "6. 点击 'Create repository'"
echo ""
echo "按回车键继续..."
read

# 添加远程仓库
echo ""
echo "======================================"
echo "步骤 2: 添加远程仓库"
echo "======================================"
echo ""

# 检查是否已存在 origin
if git remote get-url origin &>/dev/null; then
    echo "检测到已存在的远程仓库 'origin'"
    echo "是否要更新它? (y/n)"
    read -r UPDATE_ORIGIN
    if [ "$UPDATE_ORIGIN" = "y" ]; then
        git remote set-url origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
        echo "✅ 已更新远程仓库地址"
    else
        echo "⚠️  保留现有远程仓库配置"
    fi
else
    git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
    echo "✅ 已添加远程仓库: origin"
fi

echo ""
echo "远程仓库地址:"
git remote get-url origin
echo ""

# 推送到 GitHub
echo ""
echo "======================================"
echo "步骤 3: 推送到 GitHub"
echo "======================================"
echo ""

echo "正在推送代码到 GitHub..."
echo ""

# 推送 main 分支
git push -u origin main

echo ""
echo "======================================"
echo "✅ 发布成功！"
echo "======================================"
echo ""
echo "仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "下一步:"
echo "1. 访问您的仓库页面"
echo "2. 添加项目描述和标签"
echo "3. 考虑添加 GitHub Topics: searxng, docker, search-engine, china"
echo "4. 分享给其他用户 🎉"
echo ""
