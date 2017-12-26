# chatwork-vim
ChatworkAPIをVimから叩く  
自分用Script  

### 基本
ChatworkAPI version2に対応  
version1時点のコードは削除  
どのルームにアクセスできるかはローカルで管理している  

### 注意
別途secret.vimファイルを定義し、そこでTokenやルームIDを保持している  
どのようなデータが入るかはわかるようにしたので、ここを変えて使う  

strftime()を使っている場所がある  
この関数のformatはシステムに依存するらしい  
