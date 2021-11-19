class CasesController < ApplicationController
    def index
        @cases = json_params

        #render json: @cases
        @cases = @cases.sort_by {|h| [ h[:case_id].to_i, h[:timestamp].to_s ]}

         hash_time = {}
         hora_anterior = ""
 
         @cases.each do |valor|
             if !hash_time.key? (valor[:case_id].to_i) #Resumo por case_id y creo un hash
                 hash_time = hash_time.merge({valor[:case_id].to_i=>0}) 
             end
         end
 
         results = []
         hash_time.each do |k,v|
            bandera_open = false
            bandera_ws = false
            tiempo_anterior = ''
            
            suma_tiempos = 0
            
            tiempos = []
            @cases.each do |valor|    
                
                if k == valor[:case_id].to_i  #Si el case_id del resumen es igual al case_id del input, comienzo las validaciones        
                
                    if bandera_ws  & bandera_open #Si ambas condiciones se cumplieron entonces resto el timestamp actual con el anterior          
                        suma_tiempos += ((Time.parse(valor[:timestamp]) - Time.parse(tiempo_anterior))/3600).to_i
                    end
                        
                    if valor[:state].present? && valor[:state][:to].present? #Si existen los objetos, ntonces valida
                        if valor[:state][:to].to_s == 'open' #Si el estado cambia a open, entonces cambia a true la variable bandera_open
                            bandera_open = true
                        else
                            bandera_open = false   
                        end
                        
                    end
    
                    if valor[:team].present?
                        if valor[:team].to_s == 'Web Services' #Si el team cambia a Web Services, entonces cambia a true la variable bandera_ws
                            bandera_ws = true
                        else
                            bandera_ws = false
                        end
                    end                
                    
                    
                    tiempo_anterior = valor[:timestamp] #Almacena el timestamp actual para que en la siguiente iteracion pueda restarse si se cumplen las condiciones.
                    
                end#Fin if = case_id
                
            
            end#Fin iteracion casos
            
            results << {"case_id"=>k,"hours"=>suma_tiempos.to_i}
            
         
        end#Fin iteracion resumen

    end

    def json_params
        #params.permit(:case_id,:assignee,:team,:timestamp)
        #params.permit(state: [:from, :to], :case_id ) 

        params.require(:_json).map do |param| 
            param.permit(:case_id, :assignee, :team,{state: [:from, :to]}, :timestamp).to_h
        end        
    end
end
