function handleImage(image) {
  let reader = new FileReader();
  reader.onload = function() {
    let imagePreview = document.getElementById("product-image-preview");
    imagePreview.src = reader.result;
    imagePreview.className += "img-fluid w-25";
  };
  console.log(image);
  reader.readAsDataURL(image[0]);// この一行で、読み込み・入れ込みの2つをしているイメージ
    /* 新しい readerオブジェクトの中身に実際のデータを入れ込む。その後[商品登録]ボタンを押した際↓
       その readerオブジェクト自体をコントローラーへ送る */
}