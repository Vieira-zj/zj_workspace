<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>登录</el-breadcrumb-item>
      </el-breadcrumb>
      <breadcrumb v-show="false" />
    </div>
    <div id="form-container">
      <el-form id="img-form"
               ref="imgform"
               label-width="80px">
        <div>
          <el-steps :align-center="true"
                    :active="2">
            <el-step title="用户信息"></el-step>
            <el-step title="上传照片"></el-step>
          </el-steps>
        </div>
        <h1 style="text-align: center;">用 户 信 息</h1>
        <el-form-item label="用户头像">
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
        <el-form-item>
          <el-button type="primary"
                     @click="onNext">完 成</el-button>
          <el-button @click="onNext">跳 过</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { toUnicode } from '@/utils/global'
import breadcrumb from '@/components/breadcrumb'

export default {
  name: 'registerStep2',
  components: {
    breadcrumb,
  },
  data() {
    return {
      imgProps: {
        fit: 'fill',
        url: '',
      },
      uploadUrl: process.env.VUE_APP_BASE_API + '/uploadpic?isauth=n',
      uploadHeaders: {},
    }
  },
  methods: {
    onBeforeUpload(file) {
      this.uploadHeaders['Specified-User'] = this.$route.params.name
      this.uploadHeaders['X-Test'] = 'uploadfile_' + toUnicode(file.name)
    },
    onSuccessUpload(response, file, fileList) {
      console.log('upload file success:', JSON.stringify(response))
      this.imgProps.url =
        process.env.VUE_APP_BASE_API + '/downloadpic/' + response.filename
    },
    onNext() {
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

#img-form {
  position: relative;
  width: 400px;
  max-width: 100%;
  padding: 140px 35px 0;
  margin: 0 auto;
  overflow: hidden;
}
</style>
