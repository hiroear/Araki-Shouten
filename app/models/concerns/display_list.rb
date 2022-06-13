module DisplayList
  PER = 15  #マジックナンバー対策
  
  def display_list(page)
    page(page).per(PER)
  end
end