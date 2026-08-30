package br.com.fiap.petcare.exception;

/** Lancada quando a operacao fere uma regra da clinica (vira HTTP 409). */
public class BusinessException extends RuntimeException {
    public BusinessException(String mensagem) {
        super(mensagem);
    }
}
