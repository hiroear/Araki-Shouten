function handleImage(image) {
  let reader = new FileReader();   // 変数readerに生成した FileReaderオブジェクトを格納
    //ファイルの読み込みをする際は FileReaderオブジェクトを生成(new)する必要がある。ファイルの内容を非同期で取得する
  
  reader.onload = function() {     //onload: 読み取りが正常に終了するとトリガーされイベント発火
    let imagePreview = document.getElementById("product-image-preview");
    imagePreview.src = reader.result;   //生成したimgファイルの urlを imagePreviewの<img>タグsrc属性に組み込み
      //ファイルの読み込みが正常に終了し FileReaderの onloadイベントが発火した時点で、FileReaderの resultプロパティにファイルの内容(今回は imgファイルurl)が入る
    imagePreview.className += "img-fluid w-25";
  };
  console.log(image);
  reader.readAsDataURL(image[0]);
    // readAsDataURL(): fileReaderでの読込方法(FileReaderのメソッド)。画像ファイルを DataURI(L)形式として読み込む。
    // DataURL形式: 画像や音声データのURLなど(画像そのものではない)の情報。
    // 例えば画像ファイルをこのメソッドで読み込み、読み込んだデータをimg要素のsrc属性に指定すればブラウザに表示できる
}