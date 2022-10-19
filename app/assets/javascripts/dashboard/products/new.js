function handleImage(image) {
  let reader = new FileReader();   // 新しくFileReaderオブジェクトを生成 → 変数readerに格納
    //ファイルの読み込みをする際は FileReaderオブジェクトを生成(new)する必要がある。ファイルの内容を非同期で取得する
  
  reader.onload = function() {     //onload: 読み取りが正常に終了するとトリガーされイベント発火
    let imagePreview = document.getElementById("product-image-preview");
    imagePreview.src = reader.result;   //生成したimgファイルの urlを imagePreviewの<img>タグsrc属性に組み込み
      //ファイルの読み込みが正常に終了し FileReaderの onloadイベントが発火した時点で、FileReaderの resultプロパティにファイルの内容(今回は imgファイルurl)が入る
    console.log("-------------")
    console.log(reader.result)
    imagePreview.className += "img-fluid w-25";
  };
    console.log("============")
  console.log(image);
  reader.readAsDataURL(image[0]);  // この一行で、読み込み・入れ込み・送る の3つをしているイメージ
    // 新しい readerオブジェクト(インスタンス)の中身に実際のデータを入れ込み、[新規登録]ボタンを押した際その readerオブジェクト自体をコントローラーへ送る
    // readAsDataURL(): fileReaderでの読込方法(FileReaderのメソッド)。画像ファイルを DataURI(L)形式として読み込む。
    // DataURL形式: 画像や音声データのURLなど(画像そのものではない)の情報。
}