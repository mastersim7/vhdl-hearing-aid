# tb_adc.do
# Mathias Lundell
restart -f -nowave
view wave
add wave clk start led din cs sck dout

run 40us