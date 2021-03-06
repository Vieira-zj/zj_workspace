<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
          <el-breadcrumb-item to="/users"
                              v-if="isCurSuperUser">用户列表</el-breadcrumb-item>
          <el-breadcrumb-item>用户信息</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div style="float:right">
        <el-link :underline="false"
                 @click.native="onLogout">退出</el-link>
      </div>
    </div>
    <div id="form-container">
      <el-form id="user-form"
               ref="editform"
               :model="editform"
               label-width="80px">
        <h1 style="text-align: center;">用 户 信 息</h1>
        <el-form-item label="用户头像">
          <!-- <img src="../assets/user01.jpeg"
               width="100px"
               height="100px"> -->
          <el-image :fit="imgProps.fit"
                    :src="imgProps.url"
                    style="width: 100px; height: 100px">
            <div slot="error"
                 class="image-slot el-image__error">
              <i class="el-icon-picture-outline"></i>
            </div>
          </el-image>
          <el-upload :action="uploadUrl"
                     :headers="uploadHeaders"
                     :show-file-list="false"
                     :before-upload="onBeforeUpload"
                     :on-success="onSuccessUpload">
            <el-button size="small"
                       type="primary">点击上传</el-button>
            <div slot="tip"
                 class="el-upload__tip">
              只能上传jpg/png文件，且不超过500kb
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="用户姓名">
          <el-input ref="username"
                    v-model="editform.userName"
                    :disabled="true"></el-input>
        </el-form-item>
        <el-form-item label="用户昵称">
          <el-input v-model="editform.nickName"></el-input>
        </el-form-item>
        <el-form-item label="用户密码"
                      prop="password1">
          <el-input v-model="editform.password1"
                    show-password></el-input>
        </el-form-item>
        <el-form-item label="确认密码"
                      prop="password2">
          <el-input v-model="editform.password2"
                    show-password></el-input>
        </el-form-item>
        <el-form-item label="管理员">
          <el-switch v-model="editform.isSuperUser"
                     :disabled="!isCurSuperUser"></el-switch>
        </el-form-item>
        <el-form-item>
          <el-button type="primary"
                     @click="onSubmit">提 交</el-button>
          <el-button @click="onCancel">取 消</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { validatePassword, removeUserToken } from '@/utils/auth'
import { showErrorMessage, toUnicode } from '@/utils/global'
import { apiGetUser, apiEditUser } from '@/api/user'

export default {
  name: 'userEdit',
  data() {
    return {
      editform: {
        userName: '',
        nickName: '',
        isSuperUser: false,
        password1: '',
        password2: '',
      },
      isCurSuperUser: false,
      imgProps: {
        fit: 'fill',
        url: '',
      },
      uploadUrl: process.env.VUE_APP_BASE_API + '/uploadpic',
      uploadHeaders: {},
    }
  },
  async created() {
    let queryName = this.$route.params.name
    let user = this.$store.state.user
    this.isCurSuperUser = user.isSuperUser
    if (!this.isCurSuperUser && user.logonUserName !== queryName) {
      showErrorMessage('没有权限访问该用户数据！')
      return
    }

    try {
      let { user } = await apiGetUser(queryName)
      console.log('load user success:', JSON.stringify(user))
      this.editform = {
        userName: user.name,
        nickName: user.nickname,
        isSuperUser: user.issuperuser === 'y' ? true : false,
      }

      let pic = user.picture
      if (Boolean(pic) && pic.trim().length > 0) {
        this.imgProps.url = process.env.VUE_APP_BASE_API + '/downloadpic/' + pic
      }
    } catch (err) {
      console.error(err)
    }
  },
  methods: {
    onBeforeUpload(file) {
      // error: this.uploadHeaders = {}
      this.uploadHeaders['Authorization'] = this.$store.state.user.authToken
      this.uploadHeaders['Specified-User'] = this.$route.params.name
      this.uploadHeaders['X-Test'] = 'uploadfile_' + toUnicode(file.name)
    },
    onSuccessUpload(response, file, fileList) {
      console.log('upload file success:', JSON.stringify(response))
      this.imgProps.url =
        process.env.VUE_APP_BASE_API + '/downloadpic/' + response.filename
    },
    onErrorUpload(err, file, fileList) {
      console.error(err)
    },
    async onSubmit() {
      if (Boolean(this.editform.password1)) {
        if (!validatePassword(this.editform.password1)) {
          return
        }
        if (this.editform.password1 !== this.editform.password2) {
          showErrorMessage('两次输入密码不一致！')
          return
        }
      }

      let editData = {
        name: this.$route.params.name,
        data: {
          nickname: this.editform.nickName,
          issuperuser: this.editform.isSuperUser ? 'y' : 'n',
          password: this.editform.password1,
        },
      }
      try {
        let { user } = await apiEditUser(editData)
        console.log('edit user success:', JSON.stringify(user))
        this.$message({
          message: '用户信息修改成功',
          type: 'success',
        })
      } catch (err) {
        console.error(err)
      }
    },
    onCancel() {
      let last = this.$store.state.history.historyLastPage
      if (last) {
        this.$router.push(last)
      } else {
        this.$router.back(-1)
      }
    },
    onLogout() {
      removeUserToken()
      this.$router.push('/login')
    },
  },
}
</script>

<style scoped>
#form-container {
  min-height: 100%;
  width: 100%;
  overflow: hidden;
}

#user-form {
  position: relative;
  width: 380px;
  max-width: 100%;
  padding: 120px 35px 0;
  margin: 0 auto;
  overflow: hidden;
}
</style>
