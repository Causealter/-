毕业设计/
│
├── venv/                          # ✅ 虚拟环境（保留在根目录）
│
├── flask-backend/                 # 🐍 Flask 后端
│   ├── app.py                     # Flask 主入口文件
│   ├── config.py                  # 配置文件（数据库、CORS等）
│   ├── api/
│   │   ├── __init__.py
│   │   ├── music_routes.py
│   │   ├── user_routes.py
│   │   └── stats_routes.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── music_model.py
│   │   └── user_model.py
│   ├── database/
│   │   └── music.db
│   └── requirements.txt           # Flask 依赖列表
│
├── flask-music-player-frontend/   # 🎨 Vue 前端
│
├── activate_venv.bat              # 一键激活脚本
└── README.md
