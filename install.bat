@echo off
REM Muse Skill 安装脚本 (Windows)
REM 用法: install.bat                    自动检测 CLI
REM       install.bat openclaw           安装到 OpenClaw
REM       install.bat claude             安装到 Claude Code
REM       install.bat uninstall          卸载

setlocal enabledelayedexpansion

set VERSION=1.0.1
set SCRIPT_DIR=%~dp0
set DATA_DIR=%USERPROFILE%\.muse
set TARGET=%~1

REM ── 确定安装目录 ──
if "%TARGET%"=="uninstall" goto :uninstall
if "%TARGET%"=="claude" (
    set SKILL_DIR=%USERPROFILE%\.claude\skills\muse
    goto :install
)
if "%TARGET%"=="openclaw" (
    set SKILL_DIR=%USERPROFILE%\.openclaw\skills\muse
    goto :install
)
if "%TARGET%"=="kimi" (
    set SKILL_DIR=%USERPROFILE%\.config\agents\skills\muse
    goto :install
)
if "%TARGET%"=="qwen" (
    set SKILL_DIR=%USERPROFILE%\.qwen\skills\muse
    goto :install
)

REM ── 自动检测 ──
set DETECTED=
set COUNT=0

if exist "%USERPROFILE%\.openclaw" (
    set SKILL_DIR=%USERPROFILE%\.openclaw\skills\muse
    set DETECTED=OpenClaw
    set /a COUNT+=1
)
if exist "%USERPROFILE%\.claude" (
    set SKILL_DIR=%USERPROFILE%\.claude\skills\muse
    set DETECTED=Claude Code
    set /a COUNT+=1
)

if %COUNT% EQU 0 (
    echo [!] 未检测到已安装的 AI CLI，将安装到 OpenClaw 默认目录
    set SKILL_DIR=%USERPROFILE%\.openclaw\skills\muse
)
if %COUNT% GTR 1 (
    echo 检测到多个 AI CLI，请指定目标：
    echo   install.bat claude      安装到 Claude Code
    echo   install.bat openclaw    安装到 OpenClaw
    pause
    exit /b 1
)

echo [OK] 检测到 %DETECTED%

:install
REM ── Python 检查 ──
where python3 >nul 2>&1 && (set PYTHON=python3) || (
    where python >nul 2>&1 && (set PYTHON=python) || (
        echo [X] 未检测到 Python，请先安装 Python 3.6+
        pause
        exit /b 1
    )
)

echo.
echo Muse Skill v%VERSION% 安装中...

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"

REM 升级：清理旧版本
if exist "%SKILL_DIR%" (
    echo    检测到旧版本，正在升级...
    rmdir /s /q "%SKILL_DIR%"
)
mkdir "%SKILL_DIR%"

REM 复制文件（排除非运行时文件）
for %%F in ("%SCRIPT_DIR%*") do (
    set NAME=%%~nxF
    if /i not "!NAME!"=="README.md" if /i not "!NAME!"=="LICENSE" if /i not "!NAME!"=="CHANGELOG.md" if /i not "!NAME!"=="package.json" if /i not "!NAME!"=="install.sh" if /i not "!NAME!"=="install.bat" if /i not "!NAME!"==".gitignore" (
        copy "%%F" "%SKILL_DIR%\" >nul 2>&1
    )
)
for /d %%D in ("%SCRIPT_DIR%*") do (
    set NAME=%%~nxD
    if /i not "!NAME!"==".git" (
        xcopy /e /i /q "%%D" "%SKILL_DIR%\!NAME!\" >nul 2>&1
    )
)

REM ── 验证 ──
if not exist "%SKILL_DIR%\SKILL.md" (
    echo [X] 安装异常：SKILL.md 缺失
    pause
    exit /b 1
)

echo.
echo [OK] Muse Skill v%VERSION% 安装成功
echo    技能目录: %SKILL_DIR%
echo    数据目录: %DATA_DIR%
echo.
echo 在对话中发送「做首歌」即可开始创作
pause
exit /b 0

:uninstall
REM 卸载需要指定目标
if "%~2"=="" (
    echo 卸载需指定目标: install.bat uninstall openclaw
    pause
    exit /b 1
)
if "%~2"=="openclaw" set SKILL_DIR=%USERPROFILE%\.openclaw\skills\muse
if "%~2"=="claude" set SKILL_DIR=%USERPROFILE%\.claude\skills\muse
if exist "%SKILL_DIR%" (
    rmdir /s /q "%SKILL_DIR%"
    echo [OK] Muse Skill 已卸载
) else (
    echo [!] 未找到: %SKILL_DIR%
)
pause
exit /b 0
