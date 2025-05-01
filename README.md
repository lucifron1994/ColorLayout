# ColorLayoutドキュメント

## 概要
下部に5つの色付きのウィジェットボタンを配置し、ウィジェットボタンをドラッグ＆ドロップして、上部のレイアウトエリアに配置できるようにするSwiftUIビューの実装に関する技術説明です。主な機能の説明は以下の通りです。

- 初期画面
     - 挨拶メッセージを表示する。
     - 下部に5つの色付きのウィジェットボタンを配置する。  
- ドラッグ＆ドロップ機能
    - ウィジェットボタンをドラッグ＆ドロップして、上部のレイアウトエリア
に配置できるようにする。     
    - 配置されたウィジェットは指定されたエリア内に収まるようにする。
    - ドラッグ開始/終了時の触覚フィードバック。
- リセット機能。
-  アプリはiOS 17以上で動作するようにする。
-  SwiftUIを使用して実装した。

## 構成
### ファイル構成

- WidgetColor.swift: 利用可能な色を定義

- RegionNode.swift: 再帰的なノードレイアウトツリーのロジック

- ContentView.swift: メインのビューとドラッグ&ドロップUI

###  WidgetColor
- WidgetColor: 5色の列挙型。.color プロパティでSwiftUI.Colorを生成。

- Color extension: 16進数カラーコードを扱うイニシャライザを追加。

###  RegionNode
```swift
indirect enum RegionNode: Identifiable, Equatable {
    case leaf(id: UUID = UUID(), color: WidgetColor)
    case split(id: UUID = UUID(), axis: Axis, first: RegionNode, second: RegionNode)

    var id: UUID { ... }
}

extension RegionNode {
    func splitting(at point: CGPoint, in frame: CGRect, for color: WidgetColor) -> RegionNode { ... }
    func leaves(in frame: CGRect) -> [(id: UUID, color: WidgetColor, rect: CGRect)] { ... }
}
```
- RegionNode: 再帰的に分割情報を保持するツリー。

- leaf: 色付き矩形領域

- split: 2つの子ノードに分割

- splitting(at:in:for:): 既存の領域を指定点で水平 or 垂直に分割し、新しい色のノードを追加。

- leaves(in:): 再帰的にすべてのleafノードとその矩形を取得


### ContentView.swift

```swift
struct ContentView: View {
    @State private var root: RegionNode?
    @State private var previewRoot: RegionNode?
    // ... 省略 ...

    var body: some View { ... }

    private func paletteView(geo: GeometryProxy) -> some View { ... }
    private func paletteCircle(_ color: WidgetColor) -> some View { ... }
}
```


- @Stateプロパティ:

	- root: 最終確定されたレイアウトツリー

 	- previewRoot: ドラッグ中に表示するプレビュー

	- draggingColor, dragLocation, squareFrame, targetRect: ドラッグ状態の管理

- body:

	- GeometryReaderで画面サイズ取得

 	- 中央にドロップエリア、下部にパレットを表示

	- displayRootでプレビュー or 本番レイアウトを選択

- DragGesture:

 	- ドラッグ開始時にHaptic発生

 	- ドロップエリア内ならpreviewRootを更新

	- ドラッグ終了時にrootへ反映

## 動作フロー

- ユーザーがパレットから色をドラッグ

- 中央の正方形エリア上でドラッグ位置に応じた分割プレビューを表示

- ドラッグ終了でツリー構造に色領域を追加

- 以降のドラッグで任意の分割を繰り返し可能

- Resetボタンで画面の内容をリセットする
