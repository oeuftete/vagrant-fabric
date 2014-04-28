module VagrantPlugins
  module Fabric
    class Provisioner < Vagrant.plugin("2", :provisioner)
      def provision
        ssh_info = @machine.ssh_info
        user = ssh_info[:username]
        host = ssh_info[:host]
        port = ssh_info[:port]
        private_key = ssh_info[:private_key_path]

        #  After https://github.com/mitchellh/vagrant/pull/907 (Vagrant 1.4.0+),
        #  private_key_path is an array.
        if ! private_key.kind_of?(Array)
          private_key = [private_key]
        end
        private_key_option = private_key.map { |k| '-i ' + k }.join(' ')

        if config.remote == false
          system "#{config.fabric_path} -f #{config.fabfile_path} " +
                "#{private_key_option} --user=#{user} --hosts=#{host} " +
                "--port=#{port} #{config.tasks.join(' ')}"
        else
          if config.install
            @machine.communicate.sudo("pip install fabric")
            @machine.env.ui.info "Finished to install fabric library your VM."
          end
          @machine.communicate.execute("cd #{config.remote_current_dir} && " +
              "#{config.fabric_path} -f #{config.fabfile_path} " +
              "--user=#{user} --hosts=127.0.0.1 --password=#{config.remote_password} " +
              "#{config.tasks.join(' ')}")
          @machine.env.ui.info "Finished to execute tasks of fabric."
        end
      end
    end
  end
end
