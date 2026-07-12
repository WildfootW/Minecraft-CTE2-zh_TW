# Craft to Exile 2 v1.1.3 繁體中文化(台灣)

Craft to Exile 2(CTE2)v1.1.3 模組包的完整台灣繁體中文化(繁中機翻,由 Claude 產生)。

## 涵蓋範圍

| 項目 | 內容 | 規模 |
|---|---|---|
| 任務書 | FTB Quests 全 21 章 + 48 個獎勵桌 + 分頁群組 | 約 2,500 條 |
| 核心模組 | Mine and Slash(屬性/天賦/技能/詞綴/通貨/寶石/傳奇裝/介面)+ RoE Weapons、CTE2 Modpack Armors、cte_essentials、Dungeon Realm、Ancient Obelisks、Library of Exile、The Harvest | 4,118 keys |
| 其他模組 | TravelersTitles、ImmersiveMC(VR)、Small Ships、茶酒飲食模組、暮光森林首領復活台座等 44 個無人翻譯的模組 | 963 keys |
| 村民對話 | Minecraft Comes Alive(MCA)全 12 種性格對話 | 4,860 句 |

翻譯原則:Path of Exile 概念採**流亡黯道(Garena 台服)慣用譯名**(昇華、傳奇、詞綴、通貨、混沌石…),Minecraft 原版詞彙採台灣官方譯名(終界、地獄、苦力怕…),任務書與物品名稱**雙向對齊**(任務叫你拿的東西,名字跟物品顯示一致)。詳細規範見 [docs/](docs/)。

此外,repo 內建了社群翻譯包(見下方[社群翻譯來源](#社群翻譯來源與致謝)),涵蓋其餘 200+ 個一般模組(暮光森林、Botania、家具、村莊結構等),打包後**一個資源包搞定全部**。

## 目錄結構

```
resourcepack/   本專案翻譯原始檔(pack.mcmeta + assets/**/lang/zh_tw.json,63 個模組命名空間)
community/      內建的社群翻譯包(已依優先序合併,約 770 個 lang 檔 + Patchouli 手冊翻譯)
ftbquests/      任務書翻譯(chapters/、reward_tables/、chapter_groups.snbt)
extras/         選配內容(MineMenu 輪盤選單中文設定檔)
docs/           翻譯規範、術語表、英中標題對照表(title_map.tsv)
setup.ps1       互動式安裝程式(安裝/解除安裝/建置 zip,自動偵測實例位置)
```

資源包 zip 由 GitHub Actions 自動建置,可直接到 [Releases](../../releases) 下載,不必自己打包。

---

# 安裝教學:從全新安裝到完整繁中

## 前置:安裝 CTE2 1.1.3

1. 安裝 [CurseForge App](https://www.curseforge.com/download/app)
2. 搜尋並安裝模組包 **Craft to Exile 2**,版本選 **1.1.3**(Minecraft 1.20.1 / Forge 47.4.10)
3. 先啟動一次遊戲到主選單再關閉(確保實例初始化完成)

## 方法 A:一鍵安裝(推薦)

不用 clone、不用手動下載任何東西。開一個 PowerShell,執行:

```powershell
irm https://raw.githubusercontent.com/WildfootW/Minecraft-CTE2-zh_TW/master/setup.ps1 -OutFile setup.ps1
powershell -ExecutionPolicy Bypass -File setup.ps1
```

依選單操作,程式會**自動完成全部**:

- 自動偵測 CurseForge 的 CTE2 實例位置(也可手動輸入路徑)
- 需要的檔案自動從 [Releases](../../releases) 下載
- 可分項安裝:資源包(物品/介面)、任務書(原版自動備份)、H 鍵輪盤選單
- 自動把語言設為 zh_tw、啟用資源包

之後想移除,執行同一支程式選「解除安裝」即可全部還原。

> 有 clone repo 的人直接在 repo 資料夾執行 `setup.ps1` 即可,會優先用本地檔案(自行建置資源包)。

## 方法 B:手動安裝

以下用 `<實例>` 代表你的實例資料夾,通常是:
```
C:\Users\<你>\curseforge\minecraft\Instances\Craft to Exile 2
```

## 步驟 1:下載檔案

到本 repo 的 [Releases](../../releases) 頁(檔案由 GitHub Actions 自動建置):

| 檔案 | 內容 |
|---|---|
| `CTE2-v1.1.3-zh_tw-full.zip` | **完整安裝包**:資源包 + 任務書翻譯 + 輪盤選單 + setup.ps1(手動安裝下載這個;解壓後直接跑 setup.ps1 也行) |
| `CTE2-v1.1.3-zh_tw.zip` | 純資源包(只需要資源包的人用,例如伺服器已裝好任務書的玩家) |

下載 `full.zip` 並解壓,以下步驟的檔案都從解壓後的資料夾取得。

想自己建置的話:clone repo 後執行 `powershell -ExecutionPolicy Bypass -File setup.ps1 -Build`(純資源包)或 `-BuildFull`(完整包),產出在 `dist\`。

## 步驟 2:放置資源包

把 `CTE2-v1.1.3-zh_tw.zip` 複製到:

```
<實例>\config\openloader\resources\
```

(此資料夾由 OpenLoader 模組提供,CTE2 內建;沒有的話手動建立即可)

## 步驟 3:安裝任務書翻譯

1. **先備份原檔**:把 `<實例>\config\ftbquests\quests\` 整個資料夾複製一份留存(例如改名 `quests_english_backup`)
2. 把解壓後的 `ftbquests\` 底下的內容複製進 `<實例>\config\ftbquests\quests\`,覆蓋同名檔案:
   - `chapters\*.snbt`(21 個檔)
   - `reward_tables\*.snbt`(48 個檔)
   - `chapter_groups.snbt`

## 步驟 4:切換遊戲語言

進遊戲 → Options → Language → 選 **繁體中文(台灣)**。

(或直接編輯 `<實例>\options.txt`,把 `lang:` 那行改成 `lang:zh_tw`)

## 步驟 5:啟用資源包

進遊戲 → 選項 → 資源包,把 **CTE2 v1.1.3 zh_TW by WildfootW** 啟用並**移到最上層**(優先度最高)。

或直接編輯 `<實例>\options.txt` 的 `resourcePacks:` 行,在陣列**最後**加上(最後 = 最高優先):

```
"resources/CTE2-v1.1.3-zh_tw.zip"
```

例如:
```
resourcePacks:["vanilla","mod_resources", ... ,"resources/CTE2-v1.1.3-zh_tw.zip"]
```

> 編輯 options.txt 前務必先關閉遊戲,否則會被遊戲覆寫。

## 步驟 6(選配):H 鍵輪盤選單中文化

按 `H` 的輪盤選單(MineMenu)文字存在**設定檔**而非語言檔,資源包翻不到。要中文化的話,**先關閉遊戲**,把解壓後的 `extras\minemenu\menu.json` 複製到:

```
<實例>\minemenu\menu.json
```

## 完成!

進世界後:任務書(背包裡的書或快捷鍵)、Mine and Slash 介面(預設 `H`)、裝備 tooltip、進生態域的標題卡、村民對話,應該都是繁體中文了。

---

## 常見問題

**Q:模組包更新後任務書變回英文?**
CurseForge 更新模組包會重置 `config\ftbquests\quests\`,重跑一次 `setup.ps1` 安裝(或手動重做步驟 3)即可。資源包在 `openloader\resources\` 一般不會被動到,但建議確認 options.txt 的啟用項還在。

**Q:多人伺服器怎麼用?**
任務書檔案(步驟 3)要裝在**伺服器端**的 `config\ftbquests\quests\`;資源包(步驟 1-2、5)裝在**每個玩家的客戶端**。

**Q:部分物品還是英文?**
該模組可能本來就沒有任何中文翻譯(本包 + 內建社群包已涵蓋絕大多數)。歡迎開 issue 回報。

**Q:為什麼 repo 不直接放 zip?**
純文字檔對 git 友善(可 diff、可 PR、改一行不用重傳整包),zip 由 GitHub Actions 或 `setup.ps1 -Build` 隨時可重建。

## 社群翻譯來源與致謝

`community/` 內建的社群翻譯包取自巴哈姆特 Minecraft 板的 CTE2 漢化分享串(依打包時的疊合優先序,由低到高):

| 包 | 說明 |
|---|---|
| ModsTranslationPack-1.20.x | 1.20.x 通用模組繁中包(含 Patchouli 手冊翻譯) |
| ParaTranslationPack-1.20.x | 補充翻譯包(LICENSE 見 [docs/](docs/)) |
| Craft-to-Exile-2-v0.6.2 | CTE2 舊版社群漢化 |
| Craft-to-Exile-2-v0.9.2-vk | CTE2 舊版社群漢化(vk) |
| CTE2-v0.9.5-maobing | CTE2 舊版社群漢化(毛餅) |

來源討論串(巴哈姆特 Minecraft 板):
- [【己更新v0.9.3版本】Craft to Exile 2 繁化中文模組包 [CTE2]](https://forum.gamer.com.tw/C.php?bsn=18673&snA=202909)
- [【其他】Craft to Exile 2 0.95繁體中文化](https://forum.gamer.com.tw/C.php?bsn=18673&snA=204101)

感謝以上社群譯者的貢獻。若原作者對收錄方式有任何意見,請開 issue 聯繫,將立即配合處理。

## 授權

- 本專案新增之翻譯文本(resourcepack/、ftbquests/)為 Claude(Anthropic)機器翻譯,未經全面人工校對,如有錯漏歡迎開 issue 回報
- Craft to Exile 2 及各模組之內容版權歸原作者所有;本 repo 僅含翻譯文本,不含任何模組程式或素材
- 術語參考:流亡黯道(Path of Exile 台服)、Minecraft 台灣官方譯名
