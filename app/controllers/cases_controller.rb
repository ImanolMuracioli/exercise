class CasesController < ApplicationController
    def index
        @cases = json_params

        render json: @cases
    end

    def json_params
        #params.permit(:case_id,:assignee,:team,:timestamp)
        #params.permit(state: [:from, :to], :case_id ) 

        params.require(:_json).map do |param| 
            param.permit(:case_id, :assignee, :team,{state: [:from, :to]}, :timestamp).to_h
        end        
    end
end
