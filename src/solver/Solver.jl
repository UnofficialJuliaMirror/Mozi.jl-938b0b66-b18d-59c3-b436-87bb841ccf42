module Solver

include("./static_solver.jl")
include("./dynamic_solver.jl")

include("../util/mmp.jl")

using ..LoadCase

export solve

function DFSsolve(lc_node,structure,restrainedDOFs,path)
    if lc_node.case!="root"
        solve_case(structure,lc_node.case,restrainedDOFs,path)
    end
    if isempty(lc_node.children)
        return
    else
        for child in lc_node.children
            DFSsolve(child,structure,restrainedDOFs,path)
        end
    end
end

function solve_case(structure,loadcase,restrainedDOFs,path)
    working_dir=joinpath(path,".analysis")
    if is_static(loadcase)
        if loadcase.nl_type=="1st"
            u,F=solve_linear_static(structure,loadcase,restrainedDOFs)
            write_vector(working_dir,loadcase.id*"_u.v",loadcase.hid,u)
            write_vector(working_dir,loadcase.id*"_F.v",loadcase.hid,F)
        elseif loadcase.nl_type=="2nd"
            u,F=solve_2nd_static(structure,loadcase,restrainedDOFs,path=path)
            write_vector(working_dir,loadcase.id*"_u.v",loadcase.hid,u)
            write_vector(working_dir,loadcase.id*"_F.v",loadcase.hid,F)
        elseif loadcase.nl_type=="3rd"

        end
    elseif is_buckling(loadcase)
        println("Based on "*loadcase.plc)
        ω²,ϕ=solve_linear_buckling(structure,loadcase,restrainedDOFs,path=path)
        write_vector(working_dir,loadcase.id*"_o.v",loadcase.hid,ω²)
        write_matrix(working_dir,loadcase.id*"_p.m",loadcase.hid,ϕ)
    elseif is_modal(loadcase)
        if loadcase.modal_type=="eigen"
            ω²,ϕ=solve_modal_eigen(structure,loadcase,restrainedDOFs,path=path)
        elseif loadcase.modal_type=="ritz"
            ω²,ϕ=solve_modal_Ritz(structure,loadcase,restrainedDOFs,path=path)
        else
            throw("Modal method can only be eigen or ritz!")
        end
        write_vector(working_dir,loadcase.id*"_o.v",loadcase.hid,ω²)
        write_matrix(working_dir,loadcase.id*"_p.m",loadcase.hid,ϕ)
    elseif is_time_history(loadcase)
        if loadcase.algorithm=="central_diff"
            u,v,a=solve_central_diff(structure,loadcase,restrainedDOFs,path=path)
            write_matrix(working_dir,loadcase.id*"_u.m",loadcase.hid,u)
            write_matrix(working_dir,loadcase.id*"_v.m",loadcase.hid,v)
            write_matrix(working_dir,loadcase.id*"_a.m",loadcase.hid,a)
        elseif loadcase.algorithm=="newmark"
            u,v,a=solve_newmark_beta(structure,loadcase,restrainedDOFs,path=path)
            write_matrix(working_dir,loadcase.id*"_u.m",loadcase.hid,u)
            write_matrix(working_dir,loadcase.id*"_v.m",loadcase.hid,v)
            write_matrix(working_dir,loadcase.id*"_a.m",loadcase.hid,a)
        elseif loadcase.algorithm=="wilson"
            u,v,a=solve_wilson_theta(structure,loadcase,restrainedDOFs,path=path)
            write_matrix(working_dir,loadcase.id*"_u.m",loadcase.hid,u)
            write_matrix(working_dir,loadcase.id*"_v.m",loadcase.hid,v)
            write_matrix(working_dir,loadcase.id*"_a.m",loadcase.hid,a)
        elseif loadcase.algorithm=="modal_decomp"
            u,v,a=solve_modal_decomposition(structure,loadcase,restrainedDOFs,path=path)
            write_matrix(working_dir,loadcase.id*"_u.m",loadcase.hid,u)
            write_matrix(working_dir,loadcase.id*"_v.m",loadcase.hid,v)
            write_matrix(working_dir,loadcase.id*"_a.m",loadcase.hid,a)
        elseif loadcase.algorithm=="HHT"
            u,v,a=solve_newmark_beta(structure,loadcase,restrainedDOFs,path=path)
            write_matrix(working_dir,loadcase.id*"_u.m",loadcase.hid,u)
            write_matrix(working_dir,loadcase.id*"_v.m",loadcase.hid,v)
            write_matrix(working_dir,loadcase.id*"_a.m",loadcase.hid,a)
        end
    elseif is_response_spectrum(loadcase)
    end
end

# node7=LCNode(7,[])
# node4=LCNode(4,[])
# node3=LCNode(3,[])
# node6=LCNode(6,[])
#
# node2=LCNode(2,[node3,node4])
# node5=LCNode(5,[node6,node7])
#
# node1=LCNode(1,[node2])
#
# root=LCNode(0,[node1,node5])
#
# DFSsolve(root)

"""
    solve(assembly,run="all",path=pwd())
求解assembly实例
# 参数
- `assembly::Assembly`: Assembly类型实例
- `run`: 运行的工况集合，默认为全部all
- `path`: 工作路径
# 返回
- `assembly`: Assembly对象
"""
function solve(assembly,run="all")
    @info "STRUCTURE INFO" Total_DOF=assembly.nDOF Free_DOF=assembly.nfreeDOF N_Nodes=assembly.node_count N_Beams=assembly.beam_count N_Quads=assembly.quad_count
    path=assembly.working_path
    mkpath(joinpath(path,".analysis"))
    structure=assembly.structure
    restrainedDOFs=assembly.restrainedDOFs
    DFSsolve(assembly.lc_tree,structure,restrainedDOFs,path)
end

end