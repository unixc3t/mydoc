#### git术语说明

* work tree  就是指当前工作空间，或者工作目录，是git正在管理的文件夹
* index      是指的git系统索引，内容加入索引又称stage或者cache， 把内容删除索引称为unstage
* repository 就是git文档仓库



#### 修改默认的文件编辑器和比较程序

> 以下范例是把默认的编辑器换成Linux mint上的xed编辑器
> 如果要使用其他编辑器可以把xed换成该程序的具体路径

    git config --global core.editor xed