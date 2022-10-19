function handleCSV(csv) {
  let reader = new FileReader();  // 新しくFileReaderオブジェクトを生成 → 変数readerに格納
    //ファイルの読み込みをする際は FileReaderオブジェクトを生成(new)する必要がある。ファイルの内容を非同期で取得する
    
  reader.onload = function() {    //onload: 読み取りが正常に終了するとトリガーされイベント発火
    let csvName = document.getElementById("product-import-csv-filename");   //ファイル選択ボタン下の<small>タグ部分取得
    console.log(reader)
    csvName.innerHTML = csv[0].name   // <small>タグ部分に読み込んだCSVファイル名を表示
  }
  
  console.log(csv);
  reader.readAsDataURL(csv[0]);  // この一行で、読み込み・入れ込み・送る の3つをしているイメージ
    // 新しい readerオブジェクト(インスタンス)の中身に実際のデータを入れ込み、[一括登録]ボタンを押した際その readerオブジェクト自体をコントローラーへ送る
}