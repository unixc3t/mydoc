belongs_to 参数含义



~~~
class Account < ApplicationRecord
  belongs_to :supplier, foreign_key: :xx_id, primary_key: :second_id
end

~~~

```
  a = Account.first
  a.supplier
  
```

> 通常 在accounts表中找到 supplier_id(默认根据 belongs_to的参数与_id组合)的值，与suppliers表中id值匹配(默认id主键)，
> 但是设置了foreign_key和primary_key后，变成在accounts表中使用xx_id字段值与suppliers表中的second_id字段匹配
