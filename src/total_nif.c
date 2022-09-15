#ifdef __cplusplus
extern "C"
{
#endif
#include "total_nif.h"

//リソースタイプを作る．load()から呼び出される.各種nifファイルから見れるようstaticつけない
int open_resource(ErlNifEnv* env)
{
    const char* mod = "Elixir.Rclex.Nifs";

    //for init_nif.c
    const char* name1 = "rcl_ret_t";
    const char* name2 = "rcl_context_t";
    const char* name3 = "rcl_init_options_t";
    //for node_nif.c
    const char* name4 = "rcl_node_t";
    const char* name5 = "rcl_node_options_t";

    //for publisher_nif.c
    const char* name6 = "rcl_publisher_t";
    const char* name7 = "rcl_publisher_options_t";
    const char* name8 = "rosidl_message_type_support_t";
    const char* name9 = "rmw_publisher_allocation_t";
    //for subscription_nif.c
    const char* namesub1 = "rcl_subscription_t";
    const char* namesub2 = "rcl_subscription_options_t";
    const char* namesub3 = "rmw_message_info_t";
    const char* namesub4 = "rmw_subscription_allocation_t";
    //for graph_nif.c
    const char* namegraph1 = "rcl_names_and_types_t";
    //for timer
    const char* namewait1 = "rcl_allocator_t";
    const char* namewait2 = "rcl_wait_set_t";
    //for msg
    const char* namemsg0 = "void";
    int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

    rt_ret          = enif_open_resource_type(env,mod,name1,NULL,flags,NULL);
    rt_context      = enif_open_resource_type(env,mod,name2,NULL,flags,NULL);
    rt_init_options = enif_open_resource_type(env,mod,name3,NULL,flags,NULL);
    rt_node         = enif_open_resource_type(env,mod,name4,NULL,flags,NULL);
    rt_node_options = enif_open_resource_type(env,mod,name5,NULL,flags,NULL);

    rt_pub          = enif_open_resource_type(env,mod,name6,NULL,flags,NULL);
    rt_pub_options  = enif_open_resource_type(env,mod,name7,NULL,flags,NULL);
    rt_msg_type_support = enif_open_resource_type(env,mod,name8,NULL,flags,NULL);
    rt_pub_alloc = enif_open_resource_type(env,mod,name9,NULL,flags,NULL);

    rt_sub          = enif_open_resource_type(env,mod,namesub1,NULL,flags,NULL);
    rt_sub_options  = enif_open_resource_type(env,mod,namesub2,NULL,flags,NULL);
    rt_msginfo      = enif_open_resource_type(env,mod,namesub3,NULL,flags,NULL);
    rt_sub_alloc    = enif_open_resource_type(env,mod,namesub4,NULL,flags,NULL);
    rt_names_and_types = enif_open_resource_type(env,mod,namegraph1,NULL,flags,NULL);

    rt_default_alloc = enif_open_resource_type(env,mod,namewait1,NULL,flags,NULL);
    rt_waitset      = enif_open_resource_type(env,mod,namewait2,NULL,flags,NULL);

    rt_void	  = enif_open_resource_type(env,mod,namemsg0,NULL,flags,NULL);

    if(rt_node == NULL || rt_ret == NULL || rt_node_options == NULL || rt_context == NULL || rt_init_options == NULL) {
        return -1;
    }
    return 0;
}

//@on_loadで呼び出す
static int load(ErlNifEnv* env, void** priv,ERL_NIF_TERM load_info)
{
    if(open_resource(env) == -1) {
        return -1;
    }

    atom_ok = enif_make_atom(env,"ok");
    atom_true = enif_make_atom(env,"true");
    atom_false = enif_make_atom(env,"false");
    return 0;
}

static int reload(ErlNifEnv* env,void** priv,ERL_NIF_TERM load_info)
{
    return 0;
}
static int upgrade(ErlNifEnv* env,void** priv_data,void** old_priv_data,ERL_NIF_TERM load_info)
{
    return load(env,priv_data,load_info);
}
static void unload(ErlNifEnv *env, void* priv)
{
}
ErlNifFunc nif_funcs[] = {
    //-----------init_nif.c-----------
    {"rcl_get_zero_initialized_init_options",0,nif_rcl_get_zero_initialized_init_options,0},
    {"rcl_init_options_init",1,nif_rcl_init_options_init,0},
    {"rcl_init_options_fini",1,nif_rcl_init_options_fini,0},
    {"rcl_get_zero_initialized_context",0,nif_rcl_get_zero_initialized_context,0},
    {"rcl_init_with_null",2,nif_rcl_init_with_null,0},
    {"rcl_shutdown",1,nif_rcl_shutdown,0},
    //--------------node_nif.c--------------
    {"rcl_get_zero_initialized_node",0,nif_rcl_get_zero_initialized_node,0},
    {"rcl_node_get_default_options",0,nif_rcl_node_get_default_options,0},
    {"rcl_node_init",5,nif_rcl_node_init,0},
    {"rcl_node_init_without_namespace",4,nif_rcl_node_init_without_namespace,0},
    {"rcl_node_fini",1,nif_rcl_node_fini,0},
    {"read_guard_condition",1,nif_read_guard_condition,0},
    {"rcl_node_get_name",1,nif_rcl_node_get_name,0},
    //--------------publisher_nif.c-------------
    {"rcl_get_zero_initialized_publisher",0,nif_rcl_get_zero_initialized_publisher,0},
    {"rcl_publisher_get_default_options",0,nif_rcl_publisher_get_default_options,0},
    {"rcl_publisher_get_topic_name",1,nif_rcl_publisher_get_topic_name,0},
    {"rcl_publisher_fini",2,nif_rcl_publisher_fini,0},
    {"rcl_publisher_init",5,nif_rcl_publisher_init,0},
    {"rcl_publisher_is_valid",1,nif_rcl_publisher_is_valid,0},
    {"rcl_publish",3,nif_rcl_publish,0},
    {"create_pub_alloc",0,nif_create_pub_alloc,0},
    //---------------subscription_nif.c-------------
    {"rcl_get_zero_initialized_subscription",0,nif_rcl_get_zero_initialized_subscription,0},
    {"rcl_subscription_get_default_options",0,nif_rcl_subscription_get_default_options,0},
    {"create_sub_alloc",0,nif_create_sub_alloc,0},
    {"rcl_subscription_init",5,nif_rcl_subscription_init,0},
    {"rcl_subscription_fini",2,nif_rcl_subscription_fini,0},
    {"rcl_subscription_get_topic_name",1,nif_rcl_subscription_get_topic_name,0},
    {"rcl_take",4,nif_rcl_take,0},
    //---------------graph_nif.c-----------
    {"rcl_get_topic_names_and_types",3,nif_rcl_get_topic_names_and_types,0},
    //----------------wait_nif.c-----------------
    {"rcl_get_default_allocator",0,nif_rcl_get_default_allocator,0},
    {"rcl_get_zero_initialized_wait_set",0,nif_rcl_get_zero_initialized_wait_set,0},
    {"rcl_wait_set_init",9,nif_rcl_wait_set_init,0},
    {"rcl_wait_set_fini",1,nif_rcl_wait_set_fini,0},
    {"rcl_wait_set_clear",1,nif_rcl_wait_set_clear,0},
    {"rcl_wait_set_add_subscription",2,nif_rcl_wait_set_add_subscription,0},
    {"rcl_wait",2,nif_rcl_wait,0},
    {"check_waitset",2,nif_check_waitset,0},
    {"check_subscription",1,nif_check_subscription,0},
    {"get_sublist_from_waitset",1,nif_get_sublist_from_waitset,0},
    //-----<custom_msgtype>_nif.c-----start-----
    {"get_typesupport_std_msgs_msg_string",0,nif_get_typesupport_std_msgs_msg_string,0},
    {"create_empty_msg_std_msgs_msg_string",0,nif_create_empty_msg_std_msgs_msg_string,0},
    {"init_msg_std_msgs_msg_string",1,nif_init_msg_std_msgs_msg_string,0},
    {"setdata_std_msgs_msg_string",2,nif_setdata_std_msgs_msg_string,0},
    {"readdata_std_msgs_msg_string",1,nif_readdata_std_msgs_msg_string,0},
    //-----<custom_msgtype>_nif.c-----end-----
    //-------------------msg_nif.c------------------
    {"create_msginfo",0,nif_create_msginfo,0}
};

ERL_NIF_INIT(Elixir.Rclex.Nifs,nif_funcs,&load,&reload,&upgrade,&unload)
#ifdef __cplusplus
}
#endif
