
# github新建本地仓库并将代码提交到远程仓库

假设有一个工程需要提交到github相关仓库中，以前自己将工程代码提交到远程仓库都是这么干的，如下：

1、在github上新建好仓库，假设仓库名为：gitRepo。

2、使用命令git clone git@github.com:yourgithubID/gitRepo.git 克隆到本地相应的位置。

3、然后将要上传的工程代码拷贝到本地的gitRepo仓库中

4、最后使用如下的一系列命令来将其提交到远程仓库中

`1 git add *` 

`2 git commit -m "some info"`

`3 git push origin master`  


我个人觉得这种方法不好。原因在于上面的第三步：需要拷贝，如果你提交的工程代码永远不再改变，这样OK，但是，如果你的工程代码还需要修改修改再提交，修改再提交，则你就需要重新将修改后的工程代码拷贝到这个仓库，相当麻烦且容易出错哈。

自己一般写的Demo都是不再修改的，因此也就按照以上这种不太好的习惯至今。

今天就尝试了下如何直接在本地创建仓库并提交到远程仓库，记录一下。

## 具体步骤如下：

前提：在github上手动创建仓库gitRepo。

在本地按照如下的命令进行

1、 mkdir gitRepo #如果是已存在的工程项目，则直接cd到项目根目录下，不需要新建。

2、 cd gitRepo

3、 git init #初始化本地仓库

4、 git add xxx #添加要push到远程仓库的文件或文件夹

5、 git commit -m ‘first commit’

6、 git remote add origin https://github.com/yourgithubID/gitRepo.git #建立远程仓库

7、 git push -u origin master #将本地仓库push到远程仓库

## 需要注意的是：一定要在github上手动创建仓库gitRepo，否则会出现如下的错误。

![error](http://7xknzt.com1.z0.glb.clouddn.com/git_error_v3.png)

在实践过程中，由于在github上手动创建的仓库包括：README.md文件，二本地仓库没有此文件，则在执行git push -u origin master命令时报如下的错误。

![error](http://7xknzt.com1.z0.glb.clouddn.com/git_error_v1.png)

## 解决方法为：

第一步：可以通过如下命令进行代码合并【注：pull=fetch+merge]

`1 git pull --rebase origin master`

执行上面代码后可以看到本地代码库中多了README.md文件

第二步：此时再执行语句 git push -u origin master即可完成代码上传到github

![step](http://7xknzt.com1.z0.glb.clouddn.com/git_error_v4.png)

## 小结

以上就是在本地创建新的仓库并上传到远程仓库的相关命令操作。

