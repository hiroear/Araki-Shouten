function handleCSV(csv) {
  let reader = new FileReader();
  // console.log(reader)
    
  reader.onload = function() {
    let csvName = document.getElementById("product-import-csv-filename");
    csvName.innerHTML = csv[0].name   // ビュー<small>タグ部分に読み込んだCSVファイル名を表示
  }
  
  console.log(csv);
  reader.readAsDataURL(csv[0]);  // この一行で、読み込み・入れ込みの2つをしているイメージ
    /* 新しい readerオブジェクト(インスタンス)の中身に実際のデータを入れ込む。その後[一括登録]ボタンを押した際↓
       その readerオブジェクト自体をコントローラー(import_csvアクション)へ送る */
}