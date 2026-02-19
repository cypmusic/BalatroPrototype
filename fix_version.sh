#!/bin/bash
# V0.071 版本号修复脚本
# 在项目根目录运行: bash fix_version.sh

# 修复 pause_menu.gd: "V0.035 beta" → GameConfig.VERSION_LABEL
sed -i 's|"V0.035 beta"|GameConfig.VERSION_LABEL|g' scripts/pause_menu.gd

# 修复 title_screen.gd: "V0.065 beta" → GameConfig.VERSION_LABEL  
sed -i 's|"V0.065 beta"|GameConfig.VERSION_LABEL|g' scripts/title_screen.gd

echo "Done! Both files updated to use GameConfig.VERSION_LABEL"
