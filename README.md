# Craft to Exile 2 v1.1.3 繁體中文化(台灣)

Craft to Exile 2(CTE2)v1.1.3 模組包的完整台灣繁體中文化,由 WildfootW 製作(AI 輔助翻譯 + 人工校訂)。

## 涵蓋範圍

| 項目 | 內容 | 規模 |
|---|---|---|
| 任務書 | FTB Quests 全 21 章 + 48 個獎勵桌 + 分頁群組 | 約 2,500 條 |
| 核心模組 | Mine and Slash(屬性/天賦/技能/詞綴/通貨/寶石/傳奇裝/介面)+ RoE Weapons、CTE2 Modpack Armors、cte_essentials、Dungeon Realm、Ancient Obelisks、Library of Exile、The Harvest | 4,118 keys |
| 其他模組 | TravelersTitles、ImmersiveMC(VR)、Small Ships、茶酒飲食模組、暮光森林首領復活台座等 44 個無人翻譯的模組 | 963 keys |
| 村民對話 | Minecraft Comes Alive(MCA)全 12 種性格對話 | 4,860 句 |

翻譯原則:Path of Exile 概念採**流亡黯道(Garena 台服)慣用譯名**(昇華、傳奇、詞綴、通貨、混沌石…),Minecraft 原版詞彙採台灣官方譯名(終界、地獄、苦力怕…),任務書與物品名稱**雙向對齊**(任務叫你拿的東西,名字跟物品顯示一致)。詳細規範見 [docs/](docs/)。

## 目錄結構

```
resourcepack/   資源包原始檔(pack.mcmeta + assets/**/lang/zh_tw.json,共 63 個模組命名空間)
ftbquests/      任務書翻譯(chapters/、reward_tables/、chapter_groups.snbt)
docs/           翻譯規範、術語表、英中標題對照表(title_map.tsv)
build.ps1       一鍵把 resourcepack/ 打包成資源包 zip
```

---

# 安裝教學:從全新安裝到完整繁中

## 前置:安裝 CTE2 1.1.3

1. 安裝 [CurseForge App](https://www.curseforge.com/download/app)
2. 搜尋並安裝模組包 **Craft to Exile 2**,版本選 **1.1.3**(Minecraft 1.20.1 / Forge 47.4.10)
3. 先啟動一次遊戲到主選單再關閉(確保實例初始化完成)

以下用 `<實例>` 代表你的實例資料夾,通常是:
```
C:\Users\<你>\curseforge\minecraft\Instances\Craft to Exile 2
```

## 步驟 1:取得本翻譯

```
git clone <本 repo 網址>
```
或在 GitHub 頁面 Code → Download ZIP 後解壓縮。

## 步驟 2:打包資源包

在 repo 資料夾開 PowerShell,執行:

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

會產出 `dist\CTE2-v1.1.3-zh_tw-WildfootW.zip`。

> 手動打包也可以:把 `resourcepack\` **裡面的內容**(`pack.mcmeta` 和 `assets\` 要在 zip 的最上層)壓成 zip。注意:請用 7-Zip 等工具,Windows 內建「傳送到壓縮資料夾」有時會產生 Minecraft 讀不到的路徑格式,build.ps1 已避開這個問題。

## 步驟 3:放置資源包

把 `dist\CTE2-v1.1.3-zh_tw-WildfootW.zip` 複製到:

```
<實例>\config\openloader\resources\
```

(此資料夾由 OpenLoader 模組提供,CTE2 內建;沒有的話手動建立即可)

## 步驟 4:安裝任務書翻譯

1. **先備份原檔**:把 `<實例>\config\ftbquests\quests\` 整個資料夾複製一份留存(例如改名 `quests_english_backup`)
2. 把 repo 的 `ftbquests\` 底下的內容複製進 `<實例>\config\ftbquests\quests\`,覆蓋同名檔案:
   - `chapters\*.snbt`(21 個檔)
   - `reward_tables\*.snbt`(48 個檔)
   - `chapter_groups.snbt`

## 步驟 5:切換遊戲語言

進遊戲 → Options → Language → 選 **繁體中文(台灣)**。

(或直接編輯 `<實例>\options.txt`,把 `lang:` 那行改成 `lang:zh_tw`)

## 步驟 6:啟用資源包

進遊戲 → 選項 → 資源包,把 **CTE2 v1.1.3 zh_TW by WildfootW** 啟用並**移到最上層**(優先度最高)。

或直接編輯 `<實例>\options.txt` 的 `resourcePacks:` 行,在陣列**最後**加上(最後 = 最高優先):

```
"resources/CTE2-v1.1.3-zh_tw-WildfootW.zip"
```

例如:
```
resourcePacks:["vanilla","mod_resources", ... ,"resources/CTE2-v1.1.3-zh_tw-WildfootW.zip"]
```

> 編輯 options.txt 前務必先關閉遊戲,否則會被遊戲覆寫。

## 步驟 7(選配,強烈建議):一般模組漢化

本包專注於 CTE2 核心內容 + 無人翻譯的模組;其餘 200+ 個一般模組(暮光森林、Botania、家具、村莊結構等)建議再疊社群漢化包:

- **ModsTranslationPack**(1.20.x 通用模組漢化)
- **ParaTranslationPack**(補充漢化)
- **CTE2 舊版社群漢化包**(如毛餅 v0.9.5 包,可補到更多雜項)

全部放進同一個 `config\openloader\resources\` 資料夾,並在資源包選單中**排在本包之下**(options.txt 裡排在本包**之前**)。載入順序:愈後面優先度愈高,本包保持最後,確保 CTE2 核心內容以本包為準。

## 完成!

進世界後:任務書(背包裡的書或快捷鍵)、Mine and Slash 介面(預設 `H`)、裝備 tooltip、進生態域的標題卡、村民對話,應該都是繁體中文了。

---

## 常見問題

**Q:模組包更新後任務書變回英文?**
CurseForge 更新模組包會重置 `config\ftbquests\quests\`,重做「步驟 4」即可。資源包在 `openloader\resources\` 一般不會被動到,但建議確認 options.txt 的啟用項還在。

**Q:多人伺服器怎麼用?**
任務書檔案(步驟 4)要裝在**伺服器端**的 `config\ftbquests\quests\`;資源包(步驟 2-3、6)裝在**每個玩家的客戶端**。

**Q:部分物品還是英文?**
可能是步驟 7 的社群包沒裝,或該模組本來就沒有任何翻譯。歡迎開 issue 回報。

**Q:為什麼 repo 不直接放 zip?**
純文字檔對 git 友善(可 diff、可 PR、改一行不用重傳整包),zip 由 `build.ps1` 隨時可重建。

## 授權與致謝

- 翻譯文本以 Claude(Anthropic)輔助產生,WildfootW 統籌、校訂與整合
- Craft to Exile 2 及各模組之內容版權歸原作者所有;本 repo 僅含翻譯文本,不含任何模組程式或素材
- 術語參考:流亡黯道(Path of Exile 台服)、Minecraft 台灣官方譯名
