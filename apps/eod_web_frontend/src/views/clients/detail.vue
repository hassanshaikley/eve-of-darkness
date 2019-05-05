<template>
  <div class="app-container">
    <h1>{{ $route.params.username }}</h1>
    <div v-if="loaded">
      <h3>Connected: {{ client.started_at | moment("from", "now") }}</h3>
      <h3>IP Address: {{ client.ip_address }}</h3>
      <h3>Version: {{ client.version }}</h3>
      <h3>Realm: {{ client.selected_realm }}</h3>
      <h3>Selected Character: {{ client.selected_character }}</h3>
      <h3>Status: {{ is_running }}</h3>
      <el-button type="primary" @click="watchNetwork">Watch Network</el-button>
    </div>
    <div v-if="watching_network">
      Hey
    </div>
  </div>
</template>

<script>
import socket from '@/utils/socket'
import request from '@/utils/request'

export default {

  data() {
    return {
      client: {
      },
      loaded: false,
      socket: socket,
      channel: socket.channel(`clients:${this.$route.params.username}`, {}),
      client_watch_ref: null,
      network_watch_ref: null,
      watching_network: false,
      packets: []
    }
  },

  computed: {
    is_running() {
      if (this.client.is_running) {
        return 'Running'
      } else {
        return 'Stopped'
      }
    }
  },

  mounted() {
    this.initClient()
    this.socket.connect()
    this.client_watch_ref = this.channel.on('client_changed', payload => {
      this.client = payload
    })

    this.channel.join()
      .receive('ok', _ => {})
      .receive('error', _ => { console.log('client detail stream not available') })
  },

  beforeDestroy() {
    if (this.network_watch_ref !== null) {
      this.channel.off('packet_traffic', this.network_watch_ref)
    }
    this.channel.off('client_changed', this.client_watch_ref)
    this.channel.leave()
    this.socket.disconnect()
  },

  methods: {

    initClient() {
      request({ url: `/clients/${this.$route.params.username}` })
        .then(response => {
          this.client = response.data
          console.log(this.client)
          this.loaded = true
        }).catch(error => {
          console.log(['Error Loading Client', error])
        })
    },

    watchNetwork() {
      this.network_watch_ref = this.channel.on('packet_traffic', payload => {
        console.log(payload)
      })
      this.channel.push('watch_network', {})
      this.watching_network = true
    }
  }
}

</script>
