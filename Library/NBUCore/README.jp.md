iOS NBUCore
===========  
_最新バージョン 1.8.0_

個々に使用の選択が可能なコンポーネント [English](https://github.com/CyberAgent/iOS-NBUCore/blob/master/README.md)

![NBUCore](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/NBUCore.png)

Components
----------

### .xcconfig Files

複数のビルド設定（Debug、Testing、Productionなど）をしたい場合、  
.xcconfigファイルをターゲットの'build settings'に追加します。

### NBUUtil

一般的によく使われるマクロやFunction等です。

### NBULog

パフォーマンスの悪かったNSLogに取って代わるとても便利な後継者です。  
使いやすく拡張も簡単です。 参考：[Cocoa Lumberjack](https://github.com/robbiehanson/CocoaLumberjack).

### NBUAdditions

ここにあるたくさんの便利なUIKitやNSFoundationのカテゴリーは多くのアプリケーション制作に役立ちます。  
必要なものだけをImportして使うこともできます。  
**是非、みなさんがお使いの便利なカテゴリーを 'Pull Request' してNBUAdditionalsにコミットしてみてください！:-)**

Installation
------------

1. NBUCoreをプロジェクト内にチェックアウト`git@github.com:CyberAgent/iOS-NBUCore.git`するか、もしくは [ダウンロード](https://github.com/CyberAgent/iOS-NBUCore/tags)してください。  
2. その次に `NBUCore.h` 、もしくは必要なファイルだけをインポートしてください。  
3. 任意でターゲットに設定ファイル [configuration files](#nbucore_xcconfig-files) を追加します。  
 
_Keychain access は`Security.framework`のリンクが必須です。_
 
Documentation
-------------
 
* HTML: http://cyberagent.github.io/iOS-NBUCore/html/
* Xcode DocSet: `http://cyberagent.github.io/iOS-NBUCore/publish/NBUCore.atom`
 
Screenshots
-----------
 
![Dashboard](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/Dashboard.png "On-device log console")
![Dashboard minimized](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/Dashboard_minimized.png "Minimized log console")

License
-------

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

