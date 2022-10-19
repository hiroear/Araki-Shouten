module SwitchFlg
  # 引数の値が trueだったらfalseに / falseだったらtrueにスイッチ
  def switch_flg(column_of_obj)
    column_of_obj ? false : true
  end
end