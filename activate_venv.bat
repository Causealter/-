@echo off
echo ===========================================
echo     启动 Flask 虚拟环境 (venv)
echo ===========================================
echo.

REM 临时解除 PowerShell 脚本执行限制
powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"

REM 激活虚拟环境
call venv\Scripts\activate

echo.
echo ✅ 虚拟环境已激活！
echo 当前 Python 路径：
where python

echo.
echo 📦 当前 Flask 版本（如果已安装）：
python -m flask --version 2>nul || echo Flask 未安装，请执行：pip install flask

echo.
echo 完成后可输入 'deactivate' 退出虚拟环境。
cmd
