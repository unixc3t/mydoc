back= Oj.dump(sfvData)
datas= Oj.load(back)
add_rows=%w(startup onBlock onHit active recovery damage stun meterGain attackLevel moveType cancelAbility moveMotion moveButton plainCommand airmove followUp projectile extraInfo chargeDirection commonName kd kdr kdrb)
add_rows2=%w(normal-moves startup onBlock onHit active recovery damage stun meterGain attackLevel moveType cancelAbility moveMotion moveButton plainCommand airmove followUp projectile extraInfo chargeDirection commonName kd kdr kdrb)
add_rows3=%w(vtrigger startup onBlock onHit active recovery damage stun meterGain attackLevel moveType cancelAbility moveMotion moveButton plainCommand airmove followUp projectile extraInfo chargeDirection commonName kd kdr kdrb)
add_rows4=%w(health stun taunt nJump fJump fDash bDash color phrase fWalk bWalk fJumpDist bJumpDist fDashDist bDashDist throwHurt throwRange)
add_nor_col=[]
add_vtr_col=[]
add_stats_col=[]
names = []
values = []
data_all = {}

add_nor_col = ['stand LP', "stand MP", "stand HP", "stand LK", "stand MK", "stand HK", "crouch LP", "crouch MP", "crouch HP", "crouch LK", "crouch MK", "crouch HK", "jump LP", "jump MP", "jump HP", "jump LK", "jump MK", "jump HK", "Tenmakujinkyaku", "Zugaihasatsu", "Sekiseiken", "Tenha", "Kikokurenzan", "Kongoken", "Goshoha", "Shuretsuzan", "Dohatsu Shoten", "Rakan", "Rakan Gosho", "Rakan Gokyaku", "Gosenkyaku", "Gohadouken LP", "Gohadouken MP", "Gohadouken HP", "Gohadouken EX", "Sekia Goshoha LP", "Sekia Goshoha MP", "Sekia Goshoha HP", "Sekia Goshoha EX", "Zanku Hadouken LP", "Zanku Hadouken MP", "Zanku Hadouken HP", "Zanku Hadouken EX", "Goshoryuken LP", "Goshoryuken MP", "Goshoryuken HP", "Goshoryuken EX", "Tatsumaki Zankukyaku LK", "Tatsumaki Zankukyaku MK", "Tatsumaki Zankukyaku HK", "Tatsumaki Zankukyaku EX", "Air Tatsumaki Zankukyaku LK", "Air Tatsumaki Zankukyaku MK", "Air Tatsumaki Zankukyaku HK", "Air Tatsumaki Zankukyaku EX", "Hyakki Gozan LK", "Hyakki Gozan MK", "Hyakki Gozan HK", "Hyakki Gozan EX", "Hyakkishu LK > Hyakki Gosho", "Hyakkishu MK > Hyakki Gosho", "Hyakkishu HK > Hyakki Gosho", "Hyakkishu EX > Hyakki Gosho", "Hyakkishu LK > Hyakki Gojin", "Hyakki Gojin EX", "Hyakkishu LK > Hyakki Gosai", "Hyakkishu MK > Hyakki Gosai", "Hyakkishu HK > Hyakki Gosai", "Hyakkishu EX > Hyakki Gosai", "Hyakki Gozanku", "Hyakki Gorasen", "Ashura Senku (fwd)", "Ashura Senku (back)", "Sekia Kuretsuha"]
add_stats_col = [:health, :stun, :taunt, :nJump, :fJump, :bJump, :fDash, :bDash, :color, :phrase, :fWalk, :bWalk, :fJumpDist, :bJumpDist, :fDashDist, :bDashDist, :throwHurt, :throwRange]

datas.each do |key, value|
  values << value[:moves][:normal]
  values << value[:moves][:vtrigger]
  values << value[:stats]


  value[:moves][:vtrigger].each do |key, value|
    add_vtr_col << key
  end
  values<< add_vtr_col
  data_all[key.to_s] = values
  values=[]
  add_vtr_col =[]
end

p = Axlsx::Package.new
wb = p.workbook
data_all.each do |key, value|


  wb.styles do |s|
    red_border = s.add_style :border => {:style => :thick, :color => 'FFFF0000'}
    blue_border = s.add_style :border => {:style => :thick, :color => 'FF0000FF'}
    green_border = s.add_style :border => {:style => :thick, :color => '458B00'}

    wb.add_worksheet(:name => key.to_s) do |sheet|
      sheet.add_row add_rows2, :style => red_border
      value[0].each do |v, val|
        add_nor_col.each do |k|
          temp =[]
          if v.to_s.downcase == k.to_s.downcase
            temp << v
            add_rows.each do |ss|
              if val.key? ss.to_sym and val[ss.to_sym].to_s.size > 0
                temp << val[ss.to_sym]
              else
                temp << ''
              end
            end
            sheet.add_row temp
          end
        end
      end
      sheet.add_row add_rows3, :style => blue_border
      value[1].each do |v, val|
        value[3].each do |k|
          temp =[]
          if v == k
            temp << v
            add_rows.each do |ss|
              if val.key? ss.to_sym and val[ss.to_sym].to_s.size > 0
                temp << val[ss.to_sym]
              else
                temp << ''
              end
            end
            sheet.add_row temp
          end
        end
      end

      sheet.add_row add_rows4, :style => green_border

      temp = []
      add_stats_col.each do |k|
        if value[2].key? k.to_sym
          temp << value[2][k.to_sym]
        else
          temp << ''
        end
      end
      sheet.add_row temp

    end
  end

end

p.serialize("example3.xlsx")
