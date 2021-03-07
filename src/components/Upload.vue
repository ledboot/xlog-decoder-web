<template>
  <div>
    <a-row>
      <a-col :span="8">
        <img alt="logo" width="250" height="250" src="@/assets/logo.png" />
      </a-col>
      <a-col :span="14">
        <a-upload-dragger
          name="file"
          :multiple="true"
          :file-list="fileList"
          :remove="handleRemove"
          :before-upload="beforeUpload"
        >
          <p class="ant-upload-drag-icon">
            <a-icon type="inbox" />
          </p>
          <p class="ant-upload-text">点击或者拖拽文件到这个区域</p>
          <p class="ant-upload-hint">上传xlog加密压缩文件</p>
        </a-upload-dragger>
        <a-button
          type="primary"
          :disabled="fileList.length === 0"
          :loading="uploading"
          style="margin-top: 16px"
          @click="handleUpload"
        >
          {{ uploading ? 'Uploading' : 'Start Upload' }}
        </a-button>
      </a-col>
      <a-col :span="2" />
    </a-row>
  </div>
</template>
<script>
  import axios from '@/utils/request'
  export default {
    data() {
      return {
        fileList: [],
        uploading: false,
      }
    },
    methods: {
      handleChange(info) {
        const status = info.file.status
        if (status !== 'uploading') {
          console.log(info.file, info.fileList)
        }
        if (status === 'done') {
          this.$message.success(`${info.file.name} file uploaded successfully.`)
        } else if (status === 'error') {
          this.$message.error(`${info.file.name} file upload failed.`)
        }
      },
      handleRemove(file) {
        const index = this.fileList.indexOf(file)
        const newFileList = this.fileList.slice()
        newFileList.splice(index, 1)
        this.fileList = newFileList
      },
      beforeUpload(file) {
        this.fileList = [...this.fileList, file]
        return false
      },
      handleUpload() {
        const { fileList } = this
        const formData = new FormData()
        fileList.forEach((file) => {
          formData.append('files', file)
        })
        this.uploading = true

        // You can use any AJAX library you like
        axios
          .post('/xloger/v1/upload', formData, {
            'Content-Type': 'multipart/form-data',
          })
          .then((data) => {
            this.fileList = []
            this.uploading = false
            this.$message.success('upload successfully.' + data.message)
          })
      },
    },
  }
</script>
