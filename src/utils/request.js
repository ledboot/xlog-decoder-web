import axios from 'axios'
import { baseURL, contentType, requestTimeout, successCode } from '@/config'
import { isArray } from '@/utils/validate'
/**
 * @author chuzhixin 1204505056@qq.com
 * @description axios初始化
 */
const instance = axios.create({
  baseURL,
  timeout: requestTimeout,
  headers: {
    'Content-Type': contentType,
  },
})

instance.interceptors.response.use(
  (response) => {
    const { data, config } = response
    const { status, message } = data
    // 操作正常Code数组
    const codeVerificationArray = isArray(successCode)
      ? [...successCode]
      : [...[successCode]]
    // 是否操作正常
    if (codeVerificationArray.includes(status)) {
      return data
    } else {
      return Promise.reject(
        '请求异常拦截:' +
          JSON.stringify({ url: config.url, status, message }) || 'Error'
      )
    }
  },
  (error) => {
    if (error.response && error.response.data) {
      return Promise.reject(error)
    } else {
      let { message } = error
      if (message === 'Network Error') {
        message = '后端接口连接异常'
      }
      if (message.includes('timeout')) {
        message = '后端接口请求超时'
      }
      if (message.includes('Request failed with status code')) {
        const code = message.substr(message.length - 3)
        message = '后端接口' + code + '异常'
      }
      message.error(message || `后端接口未知异常`)
      return Promise.reject(error)
    }
  }
)

export default {
  post: function (url, params, header) {
    if (header) {
      return instance({
        method: 'POST',
        url: url,
        headers: header,
        data: params,
      })
    } else {
      return instance.post(url, params)
    }
  },
}
