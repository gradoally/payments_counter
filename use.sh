source config/shell_config.sh # PATHes to nessesary files

get_addr_from_file () { # pass directory to addr file and name of output var

    directory_to_addr_file=$1
    output_var_name=$2
    
    string_output_var_name="$output_var_name"
    eval $string_output_var_name=$($path_to_fift_binaries -I $fift_libs -s src/get-addr-from-file.fif $directory_to_addr_file)
    echo "Got addr from file: ${!string_output_var_name}"
    echo 'Addr saved to variable $'"${string_output_var_name}"

}

get_seqno_by_addr () { 

    net=$1
    addr=$2
    output_var_name=$3

    string_output_var_name="$output_var_name"

    for i in {1..30}
    do

        echo "Attempt to get seqno №$i"
        if [ $net = "mainnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $mainnet -v 2 -c "runmethod $addr 85143" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        elif [ $net = "testnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $testnet -v 2 -c "runmethod $addr 85143" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        else
            echo "Second argument is wrong. Should use testnet or mainnet"
        fi

        if [ ${!string_output_var_name} ];
        then
            echo "Success in attempt #$i"
            echo 'Seqno saved to variable $'"${string_output_var_name}"
            break
        fi

    done

}

get_counter_num_by_addr () { 

    net=$1
    addr=$2
    output_var_name=$3

    string_output_var_name="$output_var_name"

    for i in {1..30}
    do

        echo "Attempt to get counter_num №$i"
        if [ $net = "mainnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $mainnet -v 2 -c "runmethod $addr 85378" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        elif [ $net = "testnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $testnet -v 2 -c "runmethod $addr 85378" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        else
            echo "Second argument is wrong. Should use testnet or mainnet"
        fi

        if [ ${!string_output_var_name} ];
        then
            echo "Success in attempt #$i"
            echo 'Counter num saved to variable $'"${string_output_var_name}"
            break
        fi

    done

}

get_counter_admin_by_addr () { 

    net=$1
    addr=$2
    output_var_name=$3

    string_output_var_name="$output_var_name"

    for i in {1..30}
    do

        echo "Attempt to get counter_admin №$i"
        if [ $net = "mainnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $mainnet -v 2 -c "runmethod $addr 130666" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        elif [ $net = "testnet" ]; then
            eval $string_output_var_name=$($path_to_lite_client_binaries -v 3 --timeout 3 -C $testnet -v 2 -c "runmethod $addr 130666" | awk -v FS="(result: | remote)" '{print $2}' | tr -dc '0-9')
        else
            echo "Second argument is wrong. Should use testnet or mainnet"
        fi

        if [ ${!string_output_var_name} ];
        then
            echo "Success in attempt #$i"
            echo 'Counter num saved to variable $'"${string_output_var_name}"
            break
        fi

    done

}

create_fift_from_func_with_args () {

    input_func_file=$1
    output_fift_file=$2
    arguments=${@:3:$#}

    $path_to_func_binaries -SPA -o $output_fift_file $arguments $input_func_file

}

send_ton_to_addr () { # three arguments: dest_addr, seqno, amount, net

    $path_to_fift_binaries -I $fift_libs -s src/external-to-wallet.fif plane_garage_wallet $1 $2 $3 -n src/build/messages/send-ton-to-minter
    
    for i in {1..30}
    do

        echo "Attempt to send ton №$i"

        if [ $4 = "mainnet" ]; then
            $path_to_lite_client_binaries -v 3 --timeout 3 -C $mainnet -v 2 -c 'sendfile src/build/messages/send-ton-to-minter.boc'
        elif [ $4 = "testnet" ]; then
            $path_to_lite_client_binaries -v 3 --timeout 3 -C $testnet -v 2 -c 'sendfile src/build/messages/send-ton-to-minter.boc'
        else
            echo "Net argument is wrong. Should use testnet or mainnet"
        fi

        if [ $? == "0" ];
        then
            echo "Success in attempt #$i"
            break
        fi

    done

}

send_boc () { # [net] [msg_directory] [action_name]

    net=$1
    msg_directory=$2
    action_name=$3

    for i in {1..30}
    do

        echo "Attempt to $action_name №$i"

        if [ $net = "mainnet" ]; then
            $path_to_lite_client_binaries -v 3 --timeout 3 -C $mainnet -v 2 -c "sendfile $msg_directory"
        elif [ $net = "testnet" ]; then
            $path_to_lite_client_binaries -v 3 --timeout 3 -C $testnet -v 2 -c "sendfile $msg_directory"
        else
            echo "Net argument is wrong. Should use testnet or mainnet"
        fi

        if [ $? == "0" ];
        then
            echo "Success to $action_name in attempt #$i"
            break
        fi

    done

}

# Compile deploy wallet, no args
if [ $1 = "compile-wallet" ]; then

    action_name=$1

    $path_to_fift_binaries -I $fift_libs -s src/new-wallet.fif 0 deploy-wallet

# sh use.sh deploy-wallet [net]
elif [ $1 = "deploy-wallet" ]; then
    
    action_name=$1
    net=$2

    send_boc $net src/build/wallet/deploy-wallet-query.boc $action_name

# sh use.sh deploy-counter [net] [admin_addr] [counter_num]
elif [ $1 = "deploy-counter" ]; then

    action_name=$1
    net=$2
    admin_addr=$3
    counter_num=$4

    get_addr_from_file src/build/wallet/deploy-wallet.addr deploy_wallet_addr # get deploy-wallet addr and saves it to $deploy_wallet_addr

    create_fift_from_func_with_args $func_counter_contract src/build/counter/counter_contract.fif $func_stdlib $func_params $func_op_codes
    $path_to_fift_binaries -I $fift_libs -I $fift_contracts -s src/compile-counter.fif $admin_addr $counter_num # Запускаем скрипт, который создает boc-файл контракта минтера коллекций

    get_seqno_by_addr $net $deploy_wallet_addr deploy_wallet_seqno
    get_addr_from_file src/build/counter/counter-contract.addr counter_addr
    send_ton_to_addr $counter_addr $deploy_wallet_seqno 0.05 $net
    sleep 20
    send_boc $net src/build/counter/counter_contract_query.boc $action_name

# sh use.sh get-counter-num [net] [counter_addr]
elif [ $1 = "get-counter-num" ]; then

    action_name=$1
    net=$2
    counter_addr=$3

    get_counter_num_by_addr $net $counter_addr counter_num
    echo "Counter num: $counter_num"

# sh use.sh change-counter-admin [net] [counter_addr] [new_admin_addr]
elif [ $1 = "change-counter-admin" ]; then

    action_name=$1
    net=$2
    counter_addr=$3
    new_admin_addr=$4

    get_addr_from_file src/build/wallet/deploy-wallet.addr deploy_wallet_addr # get deploy-wallet addr and saves it to $deploy_wallet_addr
    $path_to_fift_binaries -I $fift_libs -L $fift_cli -s src/message-bodies/change-counter-admin.fif $new_admin_addr # Create boc-file of message body
    get_seqno_by_addr $net $deploy_wallet_addr deploy_wallet_seqno
    $path_to_fift_binaries -I $fift_libs -s src/external-to-wallet.fif counter_wallet $counter_addr $deploy_wallet_seqno .05 -B src/build/messages/bodies/change-counter-admin.boc -n src/build/messages/change-counter-admin-full # Add message body to message and create boc-file of full message
    msg_directory="src/build/messages/change-counter-admin-full.boc"
    send_boc $net $msg_directory $action_name

# sh use.sh get-counter-admin [net] [counter_addr]
elif [ $1 = "get-counter-admin" ]; then

    action_name=$1
    net=$2
    counter_addr=$3

    get_counter_admin_by_addr $net $counter_addr counter_admin
    echo "Counter admin: $counter_admin"

# Wrong first argument
else
    echo "First argument is wrong! Please look readme.md"
fi